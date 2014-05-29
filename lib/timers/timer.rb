# Copyright, 2014, by Tony Arcieri.
# This code is released under the MIT license. See the LICENSE file for more details.

module Timers
  # An individual timer set to fire a given proc at a given time
  class Timer
    include Comparable
    attr_reader :interval, :offset, :recurring

    def initialize(timers, interval, recurring = false, &block)
      @timers, @interval, @recurring = timers, interval, recurring
      @block  = block
      @offset = nil

      reset
    end

    def <=>(other)
      @offset <=> other.offset
    end

    # Cancel this timer
    def cancel
      @timers.cancel self
    end

    # Extend this timer
    def delay(seconds)
      @timers.delete self
      @offset += seconds
      @timers.add self
    end

    # Reset this timer
    def reset(offset = @timers.current_offset)
      @timers.cancel self if @offset
      @offset = Float(offset) + @interval
      @timers.add self
    end

    # Fire the block
    def fire(offset = @timers.current_offset)
      reset(offset) if recurring
      @block.call
    end
    alias_method :call, :fire

    # Pause this timer
    def pause
      @timers.pause self
    end

    # Continue this timer
    def continue
      @timers.continue self
    end

    # Number of seconds until next fire / since last fire
    def fires_in
      @offset - @timers.current_offset if @offset
    end

    # Inspect a timer
    def inspect
      str = "#<Timers::Timer:#{object_id.to_s(16)} "
      offset = @timers.current_offset

      if @offset
        if fires_in >= 0
          str << "fires in #{fires_in} seconds"
        else
          str << "fired #{fires_in.abs} seconds ago"
        end

        str << ", recurs every #{interval}" if recurring
      else
        str << "dead"
      end

      str << ">"
    end
  end
end