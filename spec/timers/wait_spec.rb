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

require "spec_helper"
require "timers/wait"

RSpec.describe Timers::Wait do
	it "repeats until timeout expired" do
		timeout = Timers::Wait.new(5)
		count = 0
		
		timeout.while_time_remaining do |remaining|
			expect(remaining).to be_within(TIMER_QUANTUM).of(timeout.duration - count)
			
			count += 1
			sleep 1
		end
		
		expect(count).to eq(5)
	end
	
	it "yields results as soon as possible" do
		timeout = Timers::Wait.new(5)
		
		result = timeout.while_time_remaining do |_remaining|
			break :done
		end
		
		expect(result).to eq(:done)
	end
end
