# frozen_string_literal: true

require 'griffin/socket'
require 'griffin/server'

module Griffin
  module ServerModule
    attr_reader :grpc_server

    def initialize
      @grpc_server = Griffin::Server.new
    end

    def before_run
      config[:services].each do |s|
        @grpc_server.handle(s)
      end
    end

    def stop(stop_graceful)
      super # needed
    end

    # def after_start
    # end

    # def restart
    # end

    # def reload_config
    # end
  end
end
