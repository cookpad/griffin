# frozen_string_literal: true

require 'serverengine'

require 'griffin/server_module'
require 'griffin/worker_module'

module Griffin
  class Launcher
    def initialize(config)
      @config = config
    end

    def load
      # load configuration!
    end

    def launch
      ServerEngine.create(Griffin::ServerModule, Griffin::WorkerModule, @config).run
    end
  end
end
