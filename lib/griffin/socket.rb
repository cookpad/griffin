# frozen_string_literal: true

require 'socket'

module Griffin
  # name?
  class Socket
    DEFAULT_BACKLOG_SIZE = 1024

    def initialize(host, port, backlog: nil)
      @host = host
      @port = port
      @backlog = backlog || DEFAULT_BACKLOG_SIZE
    end

    # name
    def create_listener
      sock = ::Socket.new(::Socket::AF_INET, ::Socket::SOCK_STREAM, 0)
      if true # TODO
        sock.setsockopt(::Socket::IPPROTO_TCP, ::Socket::TCP_NODELAY, 1)
      end
      sock.setsockopt(::Socket::SOL_SOCKET, ::Socket::SO_REUSEADDR, true)
      sock.bind(Addrinfo.tcp(@host, @port))
      sock.listen(@backlog)
      sock
    end
  end
end
