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

RSpec.describe Timers::Group do
	it "should not diverge too much" do
		fired = :not_fired_yet
		count = 0
		quantum = 0.01
		
		start_offset = subject.current_offset
		Timers::Timer.new(subject, quantum, :strict, start_offset) do |offset|
			fired = offset
			count += 1
		end
		
		iterations = 1000
		subject.wait while count < iterations
		
		# In my testing on the JVM, without the :strict recurring, I noticed 60ms of error here.
		expect(fired - start_offset).to be_within(quantum + TIMER_QUANTUM).of(iterations * quantum)
	end
	
	it "should only fire 0-interval timer once per iteration" do
		count = 0
		
		start_offset = subject.current_offset
		Timers::Timer.new(subject, 0, :strict, start_offset) do |offset, timer|
			count += 1
		end
		
		subject.wait
		
		expect(count).to be == 1
	end
end
