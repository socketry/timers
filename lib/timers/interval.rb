# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.

module Timers
	# A collection of timers which may fire at different times
	class Interval
		# Get the current elapsed monotonic time.
		def initialize
			@total = 0.0
			@current = nil
		end
		
		def start
			return if @current
			
			@current = now
		end
		
		def stop
			return unless @current
			
			@total += duration
			
			@current = nil
		end
		
		def to_f
			@total + duration
		end
		
		protected def duration
			now - @current
		end
		
		protected def now
			::Process.clock_gettime(::Process::CLOCK_MONOTONIC)
		end
	end
end
