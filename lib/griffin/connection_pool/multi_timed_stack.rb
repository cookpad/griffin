# frozen_string_literal: true

require 'connection_pool'

module Griffin
  module ConnectionPool
    # This code is based on https://github.com/drbrain/net-http-persistent/blob/0e5a8fb8a27deff37247ddb3bc5e6c9e390face5/lib/net/http/persistent/timed_stack_multi.rb
    class MultiTimedStack < ::ConnectionPool::TimedStack
      def initialize(size = 0, &block)
        super

        @enqueued = 0
        @ques = Hash.new { |h, k| h[k] = [] }
        @lru = []
      end

      def empty?
        length <= 0
      end

      def length
        @max - @created + @enqueued
      end

      private

      def connection_stored?(options = {})
        !@ques[options[:connection_args]].empty?
      end

      def fetch_connection(options = {})
        connection_args = options[:connection_args]

        @enqueued -= 1
        lru_update(connection_args)
        @ques[connection_args].pop
      end

      def shutdown_connections
        @ques.each_key do |key|
          super(connection_args: key)
        end
      end

      def store_connection(obj, options = {})
        @ques[options[:connection_args]].push(obj)
        @enqueued += 1
      end

      def try_create(options = {})
        connection_args = options[:connection_args]

        if @created >= @max && @enqueued >= 1
          oldest = lru_delete
          @ques[oldest].pop

          @created -= 1
        end

        if @created < @max
          obj = @create_block.call(connection_args)
          @created += 1
          lru_update(connection_args)
          obj
        end
      end

      def lru_update(key)
        @lru.delete(key)
        @lru.push(key)
      end

      def lru_delete
        @lru.shift
      end
    end
  end
end
