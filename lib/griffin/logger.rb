# frozen_string_literal: true

module Griffin
  class Logger
    class << self
      def create(config)
        ServerEngine::DaemonLogger.new(logdev_from_config(config), config)
      end

      def logdev_from_config(config)
        case c = config[:log]
        when nil  # default
          STDERR
        when '-'
          STDOUT
        else
          c
        end
      end
    end
  end
end
