# frozen_string_literal: true

# Copyright, 2018, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require_relative "timer"

module Timers
	# Maintains an ordered list of events, which can be cancelled.
	class Events
		# Represents a cancellable handle for a specific timer event.
		class Handle
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

			def > other
				@time > other.to_f
			end

			def >= other
				@time >= other.to_f
			end

			def to_f
				@time
			end

			# Fire the callback if not cancelled with the given time parameter.
			def fire(time)
				@callback.call(time) if @callback
			end
		end

		def initialize
			# A sequence of handles, maintained in sorted order, future to present.
			# @sequence.last is the next event to be fired.
			@sequence = []
			@queue = []
		end

		# Add an event at the given time.
		def schedule(time, callback)
			handle = Handle.new(time.to_f, callback)
			
			@queue << handle
			
			return handle
		end

		# Returns the first non-cancelled handle.
		def first
			merge!
			
			while (handle = @sequence.last)
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
			
			while handle = @sequence.last and handle.time <= time
				@sequence.pop
				handle.fire(time)
			end
		end

		private

		def merge!
			while handle = @queue.pop
				next if handle.cancelled?
				
				index = bisect_right(@sequence, handle)
				
				if current_handle = @sequence[index] and current_handle.cancelled?
					# puts "Replacing handle at index: #{index} due to cancellation in array containing #{@sequence.size} item(s)."
					@sequence[index] = handle
				else
					# puts "Inserting handle at index: #{index} in array containing #{@sequence.size} item(s)."
					@sequence.insert(index, handle)
				end
			end
		end

		# Return the right-most index where to insert item e, in a list a, assuming
		# a is sorted in descending order.
		def bisect_right(a, e, l = 0, u = a.length)
			while l < u
				m = l + (u - l).div(2)

				if a[m] >= e
					l = m + 1
				else
					u = m
				end
			end

			l
		end
	end
end
