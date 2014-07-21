
require 'forwardable'
require 'hitimes'

require 'timers/timer'

module Timers
  # Maintains an ordered list of events, which can be cancelled. Efficient O(logN) insertion, pop(k), and efficient O(1) cancellation.
  class Events
    class Handle
      def initialize(time, callback)
        @time = time.to_f
        @callback = callback
      end
      
      attr :time
      
      def cancel!
        @callback = nil
      end
      
      def cancelled?
        @callback == nil
      end
      
      def <=> other
        @time <=> other.to_f
      end
      
      def to_f
        @time
      end
      
      def fire
        if @callback
          @callback.call(@time)
        end
      end
    end
    
    def initialize
      # Maintained in sorted order:
      @sequence = []
    end
    
    attr :sequence
    
    # Add an event at the given time.
    def schedule(time, callback)
      handle = Handle.new(time, callback)
      
      index = bsearch(@sequence, handle)
      
      # Maintain sorted order, O(logN) insertion time.
      @sequence.insert(index, handle)
      
      return handle
    end
    
    # Returns the first non-cancelled handle.
    def first
      while handle = @sequence.first
        if handle.cancelled?
          @sequence.shift
        else
          return handle
        end
      end
    end
    
    # Fire all handles which are less than the given time.
    def fire(time)
      pop(time).each do |handle|
        handle.fire
      end
    end

    private

    def pop(time)
      index = bsearch(@sequence, time)
      
      return @sequence.shift(index)
    end

    def bsearch(a, e, l = 0, u = a.length - 1)
      return l if l>u
      
      m=(l+u)/2
      
      # Perhaps could be nicer way than hard coded to_f:
      c = (e <=> a[m].to_f)
      
      if c == 0
        return m
      elsif c == -1
        u = m-1
      else
        l = m+1
      end
      
      return bsearch(a,e,l,u)
    end
  end
end
