# frozen_string_literal: true

# Copyright, 2021, by Wander Hillen.
# Copyright, 2021, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

RSpec.describe Timers::PriorityHeap do
	context "when empty" do 
		it "should return nil when the first element is requested" do
			expect(subject.peek).to be_nil
		end
		
		it "should return nil when the first element is extracted" do
			expect(subject.pop).to be_nil
		end
		
		it "should report its size as zero" do
			expect(subject.size).to be_zero
		end
	end
	
	it "returns the same element after inserting a single element" do
		subject.push(1)
		expect(subject.size).to eq(1)
		expect(subject.pop).to eq(1)
		expect(subject.size).to be_zero
	end
	
	it "should return inserted elements in ascending order no matter the insertion order" do
		(1..10).to_a.shuffle.each do |e|
			subject.push(e)
		end
		
		expect(subject.size).to eq(10)
		expect(subject.peek).to eq(1)
		
		result = []
		10.times do
			result << subject.pop
		end
		
		expect(result.size).to eq(10)
		expect(subject.size).to be_zero
		expect(result.sort).to eq(result)
	end
end
