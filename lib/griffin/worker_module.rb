# frozen_string_literal: true

require 'griffin/socket'

module Griffin
  module WorkerModule
    def initialize
      @socket = Griffin::Socket.new(config[:bind], config[:port])
    end

    def before_fork
    end

    def run
      @sock = @socket.create_listener
      server.grpc_server.run(@sock)
    end

    def after_fork
    end

    def stop
      server.grpc_server.shutdown
      @sock.close
    end

    def reload
    end
  end
end
