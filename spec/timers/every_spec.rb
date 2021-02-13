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
	it "should fire several times" do
		result = []
		
		subject.every(0.7) { result << :a }
		subject.every(2.3) { result << :b }
		subject.every(1.3) { result << :c }
		subject.every(2.4) { result << :d }
		
		Timers::Wait.for(2.5) do |remaining|
			subject.wait if subject.wait_interval < remaining
		end
		
		expect(result).to be == [:a, :c, :a, :a, :b, :d]
	end
	
	it "should fire immediately and then several times later" do
		result = []
		
		subject.every(0.7) { result << :a }
		subject.every(2.3) { result << :b }
		subject.now_and_every(1.3) { result << :c }
		subject.now_and_every(2.4) { result << :d }
		
		Timers::Wait.for(2.5) do |remaining|
			subject.wait if subject.wait_interval < remaining
		end
		
		expect(result).to be == [:c, :d, :a, :c, :a, :a, :b, :d]
	end
end
