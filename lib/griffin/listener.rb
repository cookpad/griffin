# frozen_string_literal: true

require 'socket'

module Griffin
  class Listener
    DEFAULT_BACKLOG_SIZE = 1024

    # @params host [String]
    # @params port [Integer]
    # @params backlog [Integer]
    def initialize(host, port, backlog: DEFAULT_BACKLOG_SIZE)
      @host = host
      @port = port
      @backlog = backlog
    end

    def listen(tcp_opt: true)
      @sock = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
      if tcp_opt
        @sock.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
      end

      @sock.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEPORT, true)

      @sock.bind(Addrinfo.tcp(@host, @port))
      @sock.listen(@backlog)
      Griffin.logger.info("Start listening #{@host}:#{@port}")
      @sock
    end

    def close
      @sock.close
    end
  end
end
