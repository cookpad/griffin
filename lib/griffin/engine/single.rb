# frozen_string_literal: true

require 'griffin/server'
require 'griffin/listener'

module Griffin
  module Engine
    class Single
      def self.create(config)
        serv = Griffin::Server.new(
          min_pool_size: config[:min_pool_size],
          max_pool_size: config[:max_pool_size],
          min_connection_size: config[:min_connection_size],
          max_connection_size: config[:max_connection_size],
          interceptors: config[:interceptors],
        )
        new(serv, config)
      end

      def initialize(server, config)
        @server = server
        @config = config
        @listener = Griffin::Listener.new(@config[:bind], @config[:port])
      end

      def run
        @config[:services].each do |s|
          @server.handle(s)
        end

        install_handler

        @server.before_run
        @server.run(@listener.listen)
      end

      def install_handler
        trap('INT') do
          @server.shutdown
        end

        trap('TERM') do
          @server.shutdown
        end
      end
    end
  end
end
