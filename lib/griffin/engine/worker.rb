# frozen_string_literal: true

module Griffin
  module Engine
    module Worker
      def initialize
        @socket_manager = ServerEngine::SocketManager::Client.new(server.socket_manager_path)
      end

      def before_fork
        server.core.before_run(worker_id)
      end

      def run
        @lsock = @socket_manager.listen_tcp(config[:bind], config[:port])
        @lsock.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
        server.core.run(@lsock)
      ensure
        @lsock.close if @lsock
      end

      def stop
        server.core.shutdown
      end

      # def after_fork; end
      # def reload; end
    end
  end
end
