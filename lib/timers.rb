require 'set'
require "timers/version"

# Low precision timers implemented in pure Ruby
class Timers
  extend  Forwardable
  include Enumerable
  def_delegators :@timers, :add, :delete, :each, :empty?

  def initialize
    @timers = SortedSet.new
  end

  # Call the given block after the given interval
  def after(interval, &block)
    Timer.new(self, interval, false, &block)
  end

  # Call the given block periodically at the given interval
  def every(interval, &block)
    Timer.new(self, interval, true, &block)
  end

  # Wait for the next timer and fire it
  def wait
    return if @timers.empty?
    sleep wait_interval
    fire
  end

  # Interval to wait until when the next timer will fire
  def wait_interval
    @timers.first.time - Time.now unless empty?
  end

  # Fire all timers that are ready
  def fire
    return if @timers.empty?

    time = Time.now + 0.001
    while not empty? and time >= @timers.first.time
      timer = @timers.first
      @timers.delete timer
      timer.call
    end
  end

  alias_method :insert, :add
  alias_method :cancel, :delete

  # An individual timer set to fire a given proc at a given time
  class Timer
    include Comparable
    attr_reader :interval, :time, :recurring

    def initialize(timers, interval, recurring = false, &block)
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
