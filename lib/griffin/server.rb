# frozen_string_literal: true

require 'grpc_kit'

require 'griffin/engine'
require 'griffin/server_config_builder'
require 'griffin/thread_pool'

module Griffin
  class Server
    DEFAULT_BACKLOG_SIZE = 1024

    GRACEFUL_SHUTDOWN = '0'
    FORCIBLE_SHUTDOWN = '1'

    class << self
      # @param bind [String]
      # @param port [Integer,String]
      def run(bind: nil, port: nil)
        c = config_builder.build
        if c[:services].empty?
          raise 'Required at least one service to handle reqeust'
        end

        opts = { bind: bind, port: port }.compact
        Griffin::Engine.start(c.merge(opts), cluster: Integer(c[:workers]) > 1)
      end

      def configure
        yield(config_builder)
      end

      def config_builder
        @config_builder ||= Griffin::ServerConfigBuilder.new
      end
    end

    # @param pool_size [Integer] Worker thread size
    # @param interceptors [Array<GrpcKit::GRPC::ServerInterceptor>] list of interceptors
    def initialize(pool_size:, interceptors: [], **opts)
      @worker_size = pool_size
      @server = GrpcKit::Server.new(interceptors: interceptors)
      @opts = opts
      @status = :run
      @worker_id = 0
    end

    def handle(handler)
      @server.handle(handler)
      klass = handler.is_a?(Class) ? handler : handler.class
      klass.rpc_descs.each_key do |path|
        Griffin.logger.info("Handle #{path}")
      end
    end

    def before_run(worker_id = 0)
      @worker_id = worker_id

      # To separete fd with other forked process
      @socks = []
      @command, @signal = IO.pipe
      @socks << @command
    end

    def run(sock, blocking: true)
      @socks << sock

      @thread_pool = Griffin::ThreadPool.new(@worker_size) do |conn|
        @server.run(conn)
      end

      if blocking
        handle_server
      else
        Thread.new { handle_server }
      end
    end

    def shutdown(reason = GRACEFUL_SHUTDOWN)
      @signal.write(reason)
    end

    private

    def handle_server
      while @status == :run
        io = IO.select(@socks, [], [])

        io[0].each do |sock|
          if sock == @command
            break if handle_command
          end

          begin
            conn = sock.accept_nonblock
            @thread_pool.schedule(conn[0])
          rescue IO::WaitReadable, Errno::EINTR => e
            Griffin.logger.debug("Error raised #{e}")
            # nothing
          end
        end
      end

      # Need Timeout?
      @thread_pool.shutdown
      @command.close
      @signal.close
    end

    def handle_command
      case @command.read(1)
      when FORCIBLE_SHUTDOWN
        Griffin.logger.info("Shutting down sever(id=#{@worker_id}) forcibly...")

        @status = :halt
        @server.force_shutdown
        true
      when GRACEFUL_SHUTDOWN
        Griffin.logger.info("Shutting down sever(id=#{@worker_id}) gracefully...")

        @status = :stop
        @server.graceful_shutdown
        true
      end
    end
  end
end
