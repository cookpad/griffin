# frozen_string_literal: true

require 'griffin/connection_pool/pool'

module Griffin
  class Client
    class << self
      def pool
        @pool ||= Griffin::ConnectionPool::Pool.new do |opts|
          s = TCPSocket.new(opts.fetch[:host], opts.fetch[:port])
          s.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
          s
        end
      end

      def register
        c = Config.new
        yield(c)
        cc = c.build

        service = cc.fetch(:service)
        stub = service.const_get(:Stub, false)

        _pool = pool

        c = Class.new(stub) do
          bind = cc.fetch(:bind)
          port = cc.fetch(:port)

          def initialize
          end

          def do_request(*)
            @conn = Griffin::BaseClient.pool.chckout(@key)
          ensure
            Griffin::BaseClient.pool.chckin(@conn, @key)
          end

          #   sock = _pool.fetch
          #   super(sock, opts)

          #   @host = bind
          #   @port = port
          #   @key = { host: @host, port: @port }.freeze
          # end



          define_method(:connection_pool) do
            @connection_pool ||= _pool
          end
          private :connection_pool
        end

        service.const_set(:Client, c)
      end
    end

    class Config
      Methods = %i(service bind port)

      def initialize
        @config = {}
      end

      Methods.each do |m|
        define_method(m) do |v|
          @config[m] = v
        end
      end

      def build
        @config
      end
    end

    # def initialize(host, port, interceptors: [])
    #   @host = host
    #   @port = port
    #   @interceptors = interceptors
    # end

    # def for(service, **opt)
    #   service.const_get(:Stub, false).new(@host, @port, **opt)
    # end

    # def start(service, **opts)
    #   ret = self.for(service, opts)

    #   if block_given?
    #     yield(ret)
    #   else
    #     ret
    #   end
    # end
  end

  # class BaseClient < GrpcKit::Client
  #   def initialize(*)
  #     super

  #     @key = { host: @host, port: @port }.freeze
  #   end

  #   private

  #   def do_request(*)
  #     @conn = Griffin::BaseClient.pool.chckout(@key)
  #     super
  #   ensure
  #     Griffin::BaseClient.pool.chckin(@conn, @key)
  #   end
  # end

  # Griffin::Client.pool # Create @pool object first to avoid race condition
  # GrpcKit::GRPC.client_base_class = Griffin::BaseClient
end
