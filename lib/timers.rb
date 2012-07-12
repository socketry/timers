require 'set'
require "timers/version"

# Low precision timers implemented in pure Ruby
class Timers
  def initialize
    @timers = SortedSet.new
  end

  # Call the given block after the given interval
  def after(interval, &block)
    Timer.new(self, interval, false, block)
  end

  # Call the given block periodically at the given interval
  def every(interval, &block)
    Timer.new(self, interval, true, block)
  end

  # Wait for the next timer and fire it
  def wait
    return if @timers.empty?

    interval = wait_interval
    sleep interval if interval >= Timer::QUANTUM
    fire
  end

  # Interval to wait until when the next timer will fire
  def wait_interval
    @timers.first.time - Time.now unless empty?
  end

  # Fire all timers that are ready
  def fire
    return if @timers.empty?

    time = Time.now + Timer::QUANTUM
    while not empty? and time > @timers.first.time
      timer = @timers.first
      @timers.delete timer
      timer.call
    end
  end

  # Insert a timer into the active timers
  def insert(timer)
    @timers.add(timer)
  end

  # Remove a given timer from the set we're monitoring
  def cancel(timer)
    @timers.delete timer
  end

  # Are there any timers pending?
  def empty?
    @timers.empty?
  end

  # An individual timer set to fire a given proc at a given time
  class Timer
    include Comparable

    # The timer system is guaranteed (at least by the specs) to be this precise
    # during normal operation. Long blocking calls within actors will delay the
    # firing of timers
    QUANTUM = 0.02

    attr_reader :interval, :time, :recurring

    def initialize(timers, interval, recurring, block)
      @timers, @interval, @recurring = timers, interval, recurring
      @block = block

      reset
    end

    def <=>(other)
      @time <=> other.time
    end

    # Cancel this timer
    def cancel
      @timers.cancel self
    end

    # Reset this timer
    def reset
      @timers.cancel self if defined?(@time)
      @time = Time.now + @interval
      @timers.insert self
    end

    # Fire the block
    def fire
      reset if recurring
      @block.call
    end
    alias_method :call, :fire
  end
end
