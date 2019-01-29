# frozen_string_literal: true

require 'griffin/listener'

module Griffin
  module Engine
    module Server
      attr_reader :core, :listener, :socket_manager_path

      def initialize
        @core = Griffin::Server.new(
          pool_size: config[:pool_size],
          min_pool_size: config[:min_pool_size],
          max_pool_size: config[:max_pool_size],
          min_connection_size: config[:min_connection_size],
          max_connection_size: config[:max_connection_size],
          interceptors: config[:interceptors],
        )
        @socket_manager_path = ServerEngine::SocketManager::Server.generate_path
        @socket_manager_server = ServerEngine::SocketManager::Server.open(@socket_manager_path)
      end

      def before_run
        config[:services].each do |s|
          @core.handle(s)
        end
      end

      def stop(stop_graceful)
        @socket_manager_server.close
        super # needed
      end

      # def after_start; end
      # def restart; end
      # def reload_config; end
    end
  end
end
