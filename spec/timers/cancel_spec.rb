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
	it "should be able to cancel twice" do
		fired = false
		
		timer = subject.after(0.1) { fired = true }
		
		2.times do
			timer.cancel
			subject.wait
		end
		
		expect(fired).to be false
	end
	
	it "should be possble to reset after cancel" do
		fired = false
		
		timer = subject.after(0.1) { fired = true }
		timer.cancel
		
		subject.wait
		
		timer.reset
		
		subject.wait
		
		expect(fired).to be true
	end
	
	it "should cancel and remove one shot timers after they fire" do
		x = 0
		
		Timers::Wait.for(2) do |_remaining|
			timer = subject.every(0.2) { x += 1 }
			subject.after(0.1) { timer.cancel }
			
			subject.wait
		end
		
		expect(subject.timers).to be_empty
		expect(x).to be == 0
	end
end
