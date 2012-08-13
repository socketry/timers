require 'rbtree'
require 'forwardable'
require 'timers/version'

# Low precision timers implemented in pure Ruby
class Timers
  include Enumerable

  def initialize
    @timers = RBTree.new
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
    i = wait_interval
    sleep i if i
    fire
  end

  # Interval to wait until when the next timer will fire
  def wait_interval(now = Time.now)
    time, _ = @timers.first
    return unless time
    time - now
  end

  # Fire all timers that are ready
  def fire(now = Time.now)
    time = now + 0.001 # Fudge 1ms in case of clock imprecision
    while (time_and_timer = @timers.first) && (time >= time_and_timer[0])
      @timers.delete time_and_timer[0]
      time_and_timer[1].fire(now)
    end
  end

  def add(timer)
    raise TypeError, "not a Timers::Timer" unless timer.is_a? Timers::Timer
    @timers[timer.time] = timer
  end

  def delete(timer)
    @timers.delete timer.time
  end

  alias_method :cancel, :delete

  def each
    return to_enum  unless block_given?
    @timers.each_value{|v| yield v}
  end

  def empty?
    @timers.empty?
  end

  # An individual timer set to fire a given proc at a given time
  class Timer
    include Comparable
    attr_reader :interval, :time, :recurring

    def initialize(timers, interval, recurring = false, &block)
      @timers, @interval, @recurring = timers, interval, recurring
      @block = block
      @time  = nil

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
    def reset(now = Time.now)
      @timers.cancel self if @time
      @time = now + @interval
      @timers.add self
    end

    # Fire the block
    def fire(now = Time.now)
      reset(now) if recurring
      @block.call
    end
    alias_method :call, :fire

    # Inspect a timer
    def inspect
      str = "#<Timers::Timer:#{object_id.to_s(16)} "
      now = Time.now

      if @time
        if @time >= now
          str << "fires in #{@time - now} seconds"
        else
          str << "fired #{now - @time} seconds ago"
        end

        str << ", recurs every #{interval}" if recurring
      else
        str << "dead"
      end

      str << ">"
    end
  end
end
