# frozen_string_literal: true

require 'connection_pool'

require 'griffin/connection_pool/multi_timed_stack'

module Griffin
  module ConnectionPool
    class Pool
      DEFAULTS = { size: 5, timeout: 5 }.freeze

      def initialize(options = {}, &block)
        raise ArgumentError, 'Connection pool requires a block' unless block

        options = DEFAULTS.merge(options)

        @size = Integer(options.fetch(:size))
        @timeout = Integer(options.fetch(:timeout))

        @available = Griffin::ConnectionPool::MultiTimedStack.new(@size, &block)
        @key = :"current-#{@available.object_id}"
        Thread.current[@key] = Hash.new { |h, k| h[k] = [] }
      end

      def checkin(key)
        stack = Thread.current[@key][key]
        raise 'no connections are checked out' if stack.empty?

        conn = stack.pop
        if stack.empty?
          @available.push(conn, connection_args: key)
        end
        nil
      end

      def checkout(key)
        stack = Thread.current[@key][key]

        conn =
          if stack.empty?
            @available.pop(connection_args: key)
          else
            stack.last
          end

        stack.push(conn)

        conn
      end

      def shutdown(&block)
        @available.shutdown(&block)
      end
    end
  end
end
