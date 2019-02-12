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

      def stop(signal = nil)
        kind = case signal
               when ServerEngine::Signals::GRACEFUL_STOP then Griffin::Server::GRACEFUL_SHUTDOWN
               when ServerEngine::Signals::IMMEDIATE_STOP then Griffin::Server::FORCE_SHUTDOWN
               when ServerEngine::Signals::GRACEFUL_RESTART then Griffin::Server::GRACEFUL_RESTART
               else Griffin::Server::GRACEFUL_SHUTDOWN
               end
        server.core.shutdown(kind)
      end

      # Overwrite to identify the kind of signal in #stop
      # https://github.com/treasure-data/serverengine/blob/a005f3535affaa5b15d1e66486d9349443398dd2/lib/serverengine/worker.rb#L61-L78
      def install_signal_handlers
        w = self
        ServerEngine::SignalThread.new do |st|
          st.trap(ServerEngine::Signals::GRACEFUL_STOP) { |s| w.stop(s) }
          st.trap(ServerEngine::Signals::IMMEDIATE_STOP, 'SIG_DFL')

          st.trap(ServerEngine::Signals::GRACEFUL_RESTART) { |s| w.stop(s) }
          st.trap(ServerEngine::Signals::IMMEDIATE_RESTART, 'SIG_DFL')

          st.trap(ServerEngine::Signals::RELOAD) {
            w.logger.reopen!
            w.reload
          }
          st.trap(ServerEngine::Signals::DETACH) { |s| w.stop(s) }

          st.trap(ServerEngine::Signals::DUMP) { w.dump }
        end
      end
    end
  end
end
