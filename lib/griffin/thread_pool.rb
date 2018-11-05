# frozen_string_literal: true

require 'griffin/counting_semaphore'

module Griffin
  class ThreadPool
    DEFAULT_POOL_SIZE = 20
    DEFAULT_QUEUE_SIZE = 512

    def initialize(pool_size = DEFAULT_POOL_SIZE, queue_size: DEFAULT_QUEUE_SIZE, &block)
      @pool_size = pool_size
      @queue_size = queue_size
      @block = block
      @shutdown = false
      @semaphore = Griffin::CountingSemaphore.new(queue_size)
      @tasks = Queue.new

      @spawned = 0
      @workers = []
      @mutex = Mutex.new

      @pool_size.times { spawn_thread }
    end

    def schedule(task, &block)
      if task.nil?
        return
      end

      if @shutdown
        raise "scheduling new task isn't allowed during shutdown"
      end

      # TODO: blocking now..
      @semaphore.wait
      @tasks.push(block || task)

      @mutex.synchronize do
        if @spawned < @pool_size
          spawn_thread
        end
      end
    end

    def shutdown
      @shutdown = true
      @pool_size.times { @tasks.push(nil) }
      sleep 1 until @workers.empty?
    end

    private

    def spawn_thread
      @spawned += 1
      worker = Thread.new(@spawned) do |i|
        Thread.current.name = "Griffin worker thread #{i}"
        Griffin.logger.debug("#{Thread.current.name} started")

        loop do
          if @shutdown
            break
          end

          task = @tasks.pop
          if task.nil?
            break
          end

          begin
            @block.call(task)
          rescue Exception => e # rubocop:disable Lint/RescueException
            Griffin.logger.error("An error occured on top level in worker #{Thread.current.name}: #{e.message} (#{e.class})\n #{Thread.current.backtrace.join("\n")}  ")
          ensure
            @semaphore.signal
          end
        end

        Griffin.logger.debug("worker thread #{Thread.current.name} is stopping")
        @mutex.synchronize do
          @spawned -= 1
          @workers.delete(worker)
        end
      end

      @workers.push(worker)
    end
  end
end
