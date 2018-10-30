# frozen_string_literal: true

require 'griffin/socket'

module Griffin
  class Runner
    def initialize(config)
      @config = config
      @server = Griffin::Server.new
    end

    def run
      @listener = Griffin::Socket.new(@config[:bind], @config[:port]).create_listener

      install_handler

      @config[:services].each { |h| @server.handle(h) }
      @server.run(@listener)
    end

    private

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
