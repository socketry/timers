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

RSpec.describe Timers::Events do
	it "should register an event" do
		fired = false
		
		callback = proc do |_time|
			fired = true
		end
		
		subject.schedule(0.1, callback)
		
		expect(subject.size).to be == 1
		
		subject.fire(0.15)
		
		expect(subject.size).to be == 0
		
		expect(fired).to be true
	end
	
	it "should register events in order" do
		fired = []
		
		times = [0.95, 0.1, 0.3, 0.5, 0.4, 0.2, 0.01, 0.9]
		
		times.each do |requested_time|
			callback = proc do |_time|
				fired << requested_time
			end
			
			subject.schedule(requested_time, callback)
		end
		
		subject.fire(0.5)
		expect(fired).to be == times.sort.first(6)
		
		subject.fire(1.0)
		expect(fired).to be == times.sort
	end
	
	it "should fire events with the time they were fired at" do
		fired_at = :not_fired
		
		callback = proc do |time|
			# The time we actually were fired at:
			fired_at = time
		end
		
		subject.schedule(0.5, callback)
		
		subject.fire(1.0)
		
		expect(fired_at).to be == 1.0
	end
end
