
module Timers
  # An individual timer set to fire a given proc at a given time
  class Timer
    include Comparable
    attr_reader :interval, :offset, :recurring

    def initialize(group, interval, recurring = false, offset = nil, &block)
      @group = group
      
      @group.timers << self
      
      @interval = interval
      @recurring = recurring
      @block = block
      @offset = offset
      
      @handle = nil
      
      # If a start offset was supplied, use that, otherwise use the current timers offset.
      reset(@offset || @group.current_offset)
    end

    def paused?
      @group.paused_timers.include? self
    end

    def pause
      return if paused?
      
      @group.timers.delete self
      @group.paused_timers.add self
      
      @handle.cancel! if @handle
      @handle = nil
    end

    def resume
      return unless paused?
      
      @group.timers.add self
      @group.paused_timers.delete self
      
      reset
    end

    alias_method :continue, :resume

    # Extend this timer
    def delay(seconds)
      @handle.cancel! if @handle
      
      @offset += seconds
      
      @handle = @group.events.schedule(@offset, self)
    end

    # Cancel this timer
    def cancel
      @handle.cancel! if @handle
      @handle = nil
      
      # This timer is no longer valid:
      @group.timers.delete self
      @group = nil
    end

    # Reset this timer
    def reset(offset = @group.current_offset)
      @handle.cancel! if @handle
      
      @offset = Float(offset) + @interval
      
      @handle = @group.events.schedule(@offset, self)
    end

    # Fire the block
    def fire(offset = @group.current_offset)
      if recurring == :strict
        # ... make the next interval strictly the last offset + the interval:
        reset(@offset)
      elsif recurring
        reset(offset)
      else
        @offset = offset
      end

      @block.call(offset)
    end

    alias_method :call, :fire

    # Number of seconds until next fire / since last fire
    def fires_in
      @offset - @group.current_offset if @offset
    end

    # Inspect a timer
    def inspect
      str = "#<Timers::Timer:#{object_id.to_s(16)} "

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
