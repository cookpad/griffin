# frozen_string_literal: true

module Griffin
  class ServerConfigBuilder
    SERVERENGINE_PRIMITIVE_CONFIGS = %i[workers bind port log pid_path log_level logger].freeze
    SERVERENGINE_BLOCK_CONFIGS = %i[before_fork after_fork].freeze
    # Users can't change these values
    SERVERENGIEN_FIXED_CONFIGS = %i[daemonize worker_type worker_process_name].freeze

    # The default size of thread pool TCP Connection
    DEFAULT_POOL_SIZE = 20
    DEFAULT_CONNECTION_SIZE = 3

    GRIFFIN_CONFIGS = [
      :max_pool_size,
      :min_pool_size,
      :max_connection_size,
      :min_connection_size,
      :http2_settings,
    ].freeze

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
      worker_type: 'process',
      workers: 1,
      bind: '0.0.0.0',
      port: 50051,
      max_pool_size: DEFAULT_POOL_SIZE,
      min_pool_size: DEFAULT_POOL_SIZE,
      max_connection_size: DEFAULT_CONNECTION_SIZE,
      min_connection_size: DEFAULT_CONNECTION_SIZE,
      interceptors: [],
      services: [],
      http2_settings: [],
    }.freeze

    def initialize
      @opts = DEFAULT_SERVER_CONFIG.dup
    end

    (SERVERENGINE_PRIMITIVE_CONFIGS).each do |name|
      define_method(name) do |value|
        @opts[name] = value
      end
    end

    SERVERENGINE_BLOCK_CONFIGS.each do |name|
      define_method(name) do |&block|
        @opts[name] = block
      end
    end

    def pool_size(min, max)
      @opts[:min_pool_size] = Integer(min)
      @opts[:max_pool_size] = Integer(max)
    end

    def connection_size(min, max)
      @opts[:min_connection_size] = Integer(min)
      @opts[:max_connection_size] = Integer(max)
    end

    def http2_settings(settings)
      @opts[:http2_settings] = settings
    end

    def interceptors(*value)
      @opts[:interceptors].concat(value).flatten!
    end

    def services(*value)
      @opts[:services].concat(value).flatten!
    end

    def build
      c = ServerConfig.new
      @opts.each do |name, value|
        c.send("#{name}=", value)
      end
    end
  end
end
