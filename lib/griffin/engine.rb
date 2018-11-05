# frozen_string_literal: true

require 'serverengine'
require 'griffin/logger'
require 'griffin/engine/single'
require 'griffin/engine/server'
require 'griffin/engine/worker'

module Griffin
  module Engine
    def self.start(config, cluster: false)
      Griffin.logger = Griffin::Logger.create(config)

      if cluster
        Griffin.logger.info("Griffin v#{Griffin::VERSION} starts as cluster mode")
        ServerEngine.create(Griffin::Engine::Server, Griffin::Engine::Worker, config).run
      else
        Griffin.logger.info("Griffin v#{Griffin::VERSION} starts as single mode")
        Griffin::Engine::Single.create(config).run
      end
    end
  end
end
