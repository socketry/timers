# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2022, by Samuel Williams.
# Copyright, 2014-2016, by Tony Arcieri.
# Copyright, 2015, by Utenmiki.
# Copyright, 2015, by Donovan Keme.

require_relative "interval"

module Timers
	# An exclusive, monotonic timeout class.
	class Wait
		def self.for(duration, &block)
			if duration
				timeout = new(duration)
				
				timeout.while_time_remaining(&block)
			else
				loop do
					yield(nil)
				end
			end
		end
		
		def initialize(duration)
			@duration = duration
			@remaining = true
		end
		
		attr_reader :duration
		attr_reader :remaining
		
		# Yields while time remains for work to be done:
		def while_time_remaining
			@interval = Interval.new
			@interval.start
			
			yield @remaining while time_remaining?
		ensure
			@interval.stop
			@interval = nil
		end
		
		private
		
		def time_remaining?
			@remaining = (@duration - @interval.to_f)
			
			@remaining > 0
		end
	end
end
