# frozen_string_literal: true

require 'grpc_kit'

require 'griffin/thread_pool'

module Griffin
  class Server
    DEFAULT_WORKER_SIZE = 10
    DEFAULT_BACKLOG_SIZE = 1024

    def initialize(worker_size: DEFAULT_WORKER_SIZE, **opts)
      @worker_size = worker_size
      @server = GrpcKit::Server.new
      @opts = opts
      @shutdown, @signal = IO.pipe
      @socks = []
      @socks << @shutdown
    end

    def handle(handler)
      @server.handle(handler)
    end

    def run(sock, blocking: true)
      @socks << sock

      @thread_pool = Griffin::ThreadPool.new(@worker_size) do |conn|
        @server.session_start(conn)
      end

      @server.run

      if blocking
        handle_server
      else
        Thread.new { handle_server }
      end
    end

    def shutdown
      @shutdown << 'finish'
    end

    private

    def handle_server
      loop do
        io = IO.select(@socks, [], [])

        io[0].each do |sock|
          if sock == @shutdown
            break
          end

          begin
            bench do
              conn = sock.accept_nonblock
              @thread_pool.schedule(conn[0])
            end
          rescue IO::WaitReadable, Errno::EINTR
            # nothing
          end
        end
      end
    end

    def bench
      require 'benchmark'
      result = Benchmark.realtime do
        yield
      end
      puts result
    end
  end
end
