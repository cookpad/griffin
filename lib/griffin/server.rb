# frozen_string_literal: true

require 'grpc_kit'

require 'griffin/thread_pool'

module Griffin
  class Server
    DEFAULT_WORKER_SIZE = 10
    DEFAULT_BACKLOG_SIZE = 1024

    def initialize(host:, port:, worker_size: DEFAULT_WORKER_SIZE, backlog: DEFAULT_BACKLOG_SIZE, **opts)
      @host = host
      @port = port
      @worker_size = worker_size
      @server = GrpcKit::Server.new
      @backlog = backlog
      @opts = opts
      @shutdown, @signal = IO.pipe
      @socks = [] << @shutdown
    end

    def handle(handler)
      @server.handle(handler)
    end

    def run(blocking: true)
      install_signal

      @thread_pool = Griffin::ThreadPool.new(@worker_size) do |conn|
        @server.session_start(conn)
      end

      @server.run
      add_listner(@host, @port)

      if blocking
        handle_server
      else
        Thread.new { handle_server }
      end
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
              @thread_pool.schedule(conn)
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

    def add_listner(host, port)
      sock = TCPServer.new(host, port)
      if true # TODO
        sock.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      end
      sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
      sock.listen(@backlog)
      @socks << sock
    end

    def install_signal
      trap('INT') do
        @shutdown << 'int singal'
      end

      trap('TERM') do
        @shutdown << 'term singal'
      end
    end
  end
end
