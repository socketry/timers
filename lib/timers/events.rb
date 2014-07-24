
require 'forwardable'
require 'hitimes'

require 'timers/timer'

module Timers
  # Maintains an ordered list of events, which can be cancelled. Efficient O(logN) insertion, pop(k), and efficient O(1) cancellation.
  class Events
    class Handle
      def initialize(time, callback)
        @time = time
        @callback = callback
      end
      
      attr :time
      
      def cancel!
        # The simplest way to keep track of cancelled status is to nullify the callback. This should also be optimal for garbage collection.
        @callback = nil
      end
      
      def cancelled?
        @callback.nil?
      end
      
      def > other
        @time > other.to_f
      end
      
      def to_f
        @time
      end
      
      # Fire the callback if not cancelled.
      def fire(time)
        if @callback
          @callback.call(time)
        end
      end
    end
    
    def initialize
      # A sequence of handles, maintained in sorted order, future to present.
      # @sequence.last is the next event to be fired.
      @sequence = []
    end
    
    # Add an event at the given time.
    def schedule(time, callback)
      handle = Handle.new(time.to_f, callback)
      
      index = bisect_left(@sequence, handle)
      
      # Maintain sorted order, O(logN) insertion time.
      @sequence.insert(index, handle)
      
      return handle
    end
    
    # Returns the first non-cancelled handle.
    def first
      while handle = @sequence.last
        if handle.cancelled?
          @sequence.pop
        else
          return handle
        end
      end
    end
    
    def size
      @sequence.size
    end
    
    # Fire all handles which are less than the given time.
    def fire(time)
      pop(time).reverse_each do |handle|
        handle.fire(time)
      end
    end

    private

    def pop(time)
      index = bisect_left(@sequence, time)
      
      return @sequence.pop(@sequence.size - index)
    end
    
    # Return the left-most index where to insert item e, in a list a, assuming a is 
    # sorted in descending order.
    def bisect_left(a, e, l = 0, u = a.length)
      while l < u
        m = l + (u-l)/2
        
        if a[m] > e
          l = m+1
        else
          u = m
        end
      end
      
      return l
    end
  end
end
