# frozen_string_literal: true

module Griffin
  class Logger
    class << self
      def setup(config)
        config[:logger] = Griffin::Logger.create(config)
        Griffin.logger = config[:logger]

        m = Module.new do
          def logger
            Griffin.logger
          end
        end
        # Not to set a logger to `Grpckit.logger` since `Grpckit.logger` prints many HTTP2 layer logs
        # If you want to print them, add environment variable `GRPC_KIT_LOGLEVEL=debug`
        GrpcKit::Grpc.extend(m)
      end

      def create(config)
        config[:logger] || ServerEngine::DaemonLogger.new(logdev_from_config(config), config)
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
