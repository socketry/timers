
require 'set'
require 'forwardable'
require 'hitimes'

require 'timers/timer'

module Timers
  class Group
    include Enumerable
    extend  Forwardable
    def_delegators :@timers, :delete, :each, :empty?

    def initialize
      @timers = SortedSet.new
      @paused_timers = SortedSet.new
      @interval = Hitimes::Interval.new
      @interval.start
    end

    # Call the given block after the given interval
    def after(interval, &block)
      Timer.new(self, interval, false, &block)
    end

    # Call the given block after the given interval has expired. +interval+
    # is measured in milliseconds.
    #
    #  Timer.new.after_milliseconds(25) { puts "fired!" }
    #
    def after_milliseconds(interval, &block)
      after(interval / 1000.0, &block)
    end
    alias_method :after_ms, :after_milliseconds

    # Call the given block periodically at the given interval
    def every(interval, &block)
      Timer.new(self, interval, true, &block)
    end

    # Wait for the next timer and fire it
    def wait
      # Repeatedly call sleep until there is no longer any wait_interval:
      while i = wait_interval
        # We cannot assume that sleep will wait for the specified time, it might be +/- a bit.
        sleep i if interval > 0
      end
      
      fire
    end

    # Interval to wait until when the next timer will fire
    def wait_interval(offset = self.current_offset)
      timer = @timers.first
      return unless timer
      timer.offset - Float(offset)
    end

    # Fire all timers that are ready
    def fire(offset = self.current_offset)
      time = Float(offset)
      while (timer = @timers.first) && (time >= timer.offset)
        @timers.delete timer
        timer.fire(offset)
      end
    end

    def add(timer)
      raise TypeError, "not a Timers::Timer" unless timer.is_a? Timers::Timer
      @timers.add(timer)
    end

    def pause(timer = nil)
      return pause_all if timer.nil?
      raise TypeError, "not a Timers::Timer" unless timer.is_a? Timers::Timer
      @timers.delete timer
      @paused_timers.add timer
    end

    def pause_all
      @timers.each {|timer| timer.pause}
    end

    def continue(timer = nil)
      return continue_all if timer.nil?
      raise TypeError, "not a Timers::Timer" unless timer.is_a? Timers::Timer
      @paused_timers.delete timer
      @timers.add timer
    end

    def continue_all
      @paused_timers.each {|timer| timer.continue}
    end

    def delay(seconds)
      @timers.each {|timer| timer.delay(seconds)}
    end

    alias_method :cancel, :delete

    def current_offset
      @interval.to_f
    end
  end
end
