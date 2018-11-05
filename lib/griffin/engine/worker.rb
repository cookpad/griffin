# frozen_string_literal: true

require 'griffin/listener'

module Griffin
  module Engine
    module WorkerModule
      def initialize
        @listener = Griffin::Listener.new(@config[:bind], @config[:port])
      end

      def run
        server.core.run(@listener.listen)
      end

      def stop
        @listener.close
        server.core.shutdown
      end

      # def after_fork; end
      # def before_fork; end
      # def reload; end
    end
  end
end