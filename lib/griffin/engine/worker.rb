# frozen_string_literal: true

require 'griffin/listener'

module Griffin
  module Engine
    module Worker
      def before_fork
        @listener = Griffin::Listener.new(config[:bind], config[:port])
        server.core.before_run(worker_id)
      end

      def run
        server.core.run(@listener.listen)
      ensure
        @listener.close
      end

      def stop
        server.core.shutdown
      end

      # def after_fork; end
      # def reload; end
    end
  end
end
