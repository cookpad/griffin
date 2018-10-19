# frozen_string_literal: true

require 'logger'
require 'grpc_kit'

require 'griffin/version'
require 'griffin/server_config'
require 'griffin/launcher'

module Griffin
  def self.logger
    @logger ||= Logger.new(STDOUT, level: :info)
  end

  def self.build_server_config
    ServerConfigBuilder.new.tap { |e| yield(e) }.build
  end
end

GrpcKit.logger = Griffin.logger
