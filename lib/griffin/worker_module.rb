# frozen_string_literal: true

require 'griffin/socket'

module Griffin
  module WorkerModule
    def initialize
      @socket = Griffin::Socket.new(config[:bind], config[:port])
    end

    def run
      @listener = @socket.create_listener
      begin
        server.grpc_server.run(@listener)
      ensure
        @listener.close
      end
    end

    def stop
      server.grpc_server.shutdown
    end

    # def after_fork
    # end

    # def before_fork
    # end

    # def reload
    # end
  end
end
