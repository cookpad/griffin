# frozen_string_literal: true

require 'serverengine'

require 'griffin/server_module'
require 'griffin/worker_module'
require 'griffin/runner'

module Griffin
  class Launcher
    def initialize(config)
      @config = config
    end

    def load
      # load configuration!
    end

    def launch
      if true || Integer(@config[:workers]) > 1
        Griffin.logger.info('Start server with cluster mode')
        ServerEngine.create(Griffin::ServerModule, Griffin::WorkerModule, @config).run
      else
        Griffin.logger.info('Start server with single mode')
        Griffin::Runner.new(@config).run
      end
    end
  end
end
