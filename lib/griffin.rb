# frozen_string_literal: true

require 'logger'
require 'grpc_kit'

require 'griffin/server'
require 'griffin/version'

module Griffin
  def self.logger
    @logger ||= Logger.new($stdout, level: :info)
  end

  def self.logger=(logger)
    @logger = logger
  end
end
