
require 'set'
require 'forwardable'
require 'hitimes'

require 'timers/timer'
require 'timers/events'

module Timers
  class Group
    include Enumerable

    extend Forwardable
    def_delegators :@timers, :each, :empty?

    def initialize
      @events = Events.new
      
      @timers = Set.new
      @paused_timers = Set.new
      
      @interval = Hitimes::Interval.new
      @interval.start
    end

    # Scheduled events:
    attr :events
    
    # Active timers:
    attr :timers
    
    # Paused timers:
    attr :paused_timers

    # Call the given block after the given interval
    def after(interval, &block)
      Timer.new(self, interval, false, &block)
    end

    def after_milliseconds(interval, &block)
      after(interval / 1000.0,  &block)
    end

    # Call the given block periodically at the given interval
    def every(interval, recur = true, &block)
      Timer.new(self, interval, recur, &block)
    end

    # Wait for the next timer and fire it
    def wait(&block)
      # If no timers are present, yield nil and return:
      return yield(nil) if block_given? and empty?
      
      # Repeatedly call sleep until there is no longer any wait_interval:
      while interval = wait_interval and interval > 0
        if block_given?
          yield interval
        else
          # We cannot assume that sleep will wait for the specified time, it might be +/- a bit.
          sleep interval
        end
      end
      
      fire
    end

    # Interval to wait until when the next timer will fire.
    def wait_interval(offset = self.current_offset)
      if handle = @events.sequence.first
        return handle.time - Float(offset)
      end
    end

    # Fire all timers that are ready.
    def fire(offset = self.current_offset)
      @events.fire(offset)
    end

    # Pause all timers.
    def pause
      @timers.dup.each do |timer|
        timer.pause
      end
    end

    # Resume all timers.
    def resume
      @paused_timers.dup.each do |timer|
        timer.resume
      end
    end

    alias_method :continue, :resume

    # Delay all timers.
    def delay(seconds)
      @timers.each do |timer|
        timer.delay(seconds)
      end
    end

    # Cancel all timers.
    def cancel
      @timers.each do |timer|
        timer.cancel
      end
    end

    def current_offset
      @interval.to_f
    end
  end
end
