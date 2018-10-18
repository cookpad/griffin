# frozen_string_literal: true

module Griffin
  class CountingSemaphore
    def initialize(size)
      @size = size
      @queue = Queue.new
      # whatever value
      @size.times { @queue.push(0) }
    end

    def wait
      @queue.pop
    end

    def signal
      @queue.push(0)
    end
  end
end
