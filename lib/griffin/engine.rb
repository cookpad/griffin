# frozen_string_literal: true

require 'serverengine'
require 'griffin/engine/single'
require 'griffin/engine/server'
require 'griffin/engine/worker'

module Griffin
  module Engine
    def self.start(config, cluster: false)
      if cluster
        ServerEngine.create(Griffin::Engine::Server, Griffin::Engine::Worker, config).run
      else
        Griffin::Engine::Single.create(config).run
      end
    end
  end
end
