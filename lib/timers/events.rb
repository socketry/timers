# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2022, by Samuel Williams.
# Copyright, 2014-2016, by Tony Arcieri.
# Copyright, 2014, by Lavir the Whiolet.
# Copyright, 2015, by Utenmiki.
# Copyright, 2015, by Donovan Keme.
# Copyright, 2021, by Wander Hillen.

require_relative "timer"
require_relative "priority_heap"

module Timers
	# Maintains a PriorityHeap of events ordered on time, which can be cancelled.
	class Events
		# Represents a cancellable handle for a specific timer event.
		class Handle
			include Comparable
			
			def initialize(time, callback)
				@time = time
				@callback = callback
			end
			
			# The absolute time that the handle should be fired at.
			attr_reader :time
			
			# Cancel this timer, O(1).
			def cancel!
				# The simplest way to keep track of cancelled status is to nullify the
				# callback. This should also be optimal for garbage collection.
				@callback = nil
			end
			
			# Has this timer been cancelled? Cancelled timer's don't fire.
			def cancelled?
				@callback.nil?
			end
			
			def <=> other
				@time <=> other.time
			end
			
			# Fire the callback if not cancelled with the given time parameter.
			def fire(time)
				@callback.call(time) if @callback
			end
		end
		
		def initialize
			# A sequence of handles, maintained in sorted order, future to present.
			# @sequence.last is the next event to be fired.
			@sequence = PriorityHeap.new
			@queue = []
		end
		
		# Add an event at the given time.
		def schedule(time, callback)
			flush!
			
			handle = Handle.new(time.to_f, callback)
			
			@queue << handle
			
			return handle
		end
		
		# Returns the first non-cancelled handle.
		def first
			merge!
			
			while (handle = @sequence.peek)
				return handle unless handle.cancelled?
				@sequence.pop
			end
		end
		
		# Returns the number of pending (possibly cancelled) events.
		def size
			@sequence.size + @queue.size
		end
		
		# Fire all handles for which Handle#time is less than the given time.
		def fire(time)
			merge!
			
			while handle = @sequence.peek and handle.time <= time
				@sequence.pop
				handle.fire(time)
			end
		end
		
		private
		
		# Move all non-cancelled timers from the pending queue to the priority heap
		def merge!
			while handle = @queue.pop
				next if handle.cancelled?
				
				@sequence.push(handle)
			end
		end
		
		def flush!
			while @queue.last&.cancelled?
				@queue.pop
			end
		end
	end
end
