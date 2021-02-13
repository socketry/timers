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
