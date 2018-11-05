# frozen_string_literal: true

require 'griffin/listener'

module Griffin
  module Engine
    module Server
      attr_reader :core, :listener

      def initialize
        @core = Griffin::Server.new
      end

      def before_run
        config[:services].each do |s|
          @core.handle(s)
        end
      end

      def stop(stop_graceful)
        super # needed
      end

      # def after_start; end
      # def restart; end
      # def reload_config; end
    end
  end
end
