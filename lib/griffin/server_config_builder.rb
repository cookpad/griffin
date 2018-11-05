# frozen_string_literal: true

module Griffin
  class ServerConfigBuilder
    SERVERENGINE_PRIMITIVE_CONFIGS = %i[workers bind port log pid_path].freeze
    SERVERENGINE_BLOCK_CONFIGS = %i[before_fork after_fork].freeze
    # Users can't change these values
    SERVERENGIEN_FIXED_CONFIGS = %i[daemonize worker_type worker_process_name].freeze
    GRIFFIN_CONFIGS = %i[thread_pool].freeze
    GRPC_CONFIGS = %i[services interceptors].freeze

    ServerConfig = Struct.new(*(SERVERENGINE_PRIMITIVE_CONFIGS + SERVERENGINE_BLOCK_CONFIGS + SERVERENGIEN_FIXED_CONFIGS + GRIFFIN_CONFIGS + GRPC_CONFIGS)) do
      def to_h
        super.compact
      end
    end

    DEFAULT_SERVER_CONFIG = {
      worker_process_name: 'griffin worker',
      daemonize: false,
      log: '-', # STDOUT
      # log: 'acess.log', # STDOUT
      worker_type: 'process',
      workers: 1,
      bind: '0.0.0.0',
      port: 50051,
    }.freeze

    def initialize
      @opts = DEFAULT_SERVER_CONFIG.dup
    end

    (SERVERENGINE_PRIMITIVE_CONFIGS + GRIFFIN_CONFIGS + [:interceptors]).each do |name|
      define_method(name) do |value|
        @opts[name] = value
      end
    end

    SERVERENGINE_BLOCK_CONFIGS.each do |name|
      define_method(name) do |&block|
        @opts[name] = block
      end
    end

    def services(*serv)
      @opts[:services] = serv
    end

    def build
      c = ServerConfig.new
      @opts.each do |name, value|
        c.send("#{name}=", value)
      end
    end
  end
end
