# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Wander Hillen.
# Copyright, 2021, by Samuel Williams.

require 'timers/priority_heap'

describe Timers::PriorityHeap do
	let(:priority_heap) {subject.new}
	
	with "empty heap" do 
		it "should return nil when the first element is requested" do
			expect(priority_heap.peek).to be_nil
		end
		
		it "should return nil when the first element is extracted" do
			expect(priority_heap.pop).to be_nil
		end
		
		it "should report its size as zero" do
			expect(priority_heap.size).to be(:zero?)
		end
	end
	
	it "returns the same element after inserting a single element" do
		priority_heap.push(1)
		expect(priority_heap.size).to be == 1
		expect(priority_heap.pop).to be == 1
		expect(priority_heap.size).to be(:zero?)
	end
	
	it "should return inserted elements in ascending order no matter the insertion order" do
		(1..10).to_a.shuffle.each do |e|
			priority_heap.push(e)
		end
		
		expect(priority_heap.size).to be == 10
		expect(priority_heap.peek).to be == 1
		
		result = []
		10.times do
			result << priority_heap.pop
		end
		
		expect(result.size).to be == 10
		expect(priority_heap.size).to be(:zero?)
		expect(result.sort).to be == result
	end

	with "maintaining the heap invariant" do
		it "for empty heaps" do
			expect(priority_heap).to be(:valid?)
		end

		it "for heap of size 1" do
			priority_heap.push(123)
			expect(priority_heap).to be(:valid?)
		end
		# Exhaustive testing of all permutations of [1..6]
		it "for all permutations of size 6" do
			[1,2,3,4,5,6].permutation do |arr|
				priority_heap.clear!
				arr.each { |e| priority_heap.push(e) }
				expect(priority_heap).to be(:valid?)
			end
		end

		# A few examples with more elements (but not ALL permutations)
		it "for larger amounts of values" do
			5.times do
				priority_heap.clear!
				(1..1000).to_a.shuffle.each { |e| priority_heap.push(e) }
				expect(priority_heap).to be(:valid?)
			end
		end

		# What if we insert several of the same item along with others?
		it "with several elements of the same value" do
			test_values = (1..10).to_a + [4] * 5
			test_values.each { |e| priority_heap.push(e) }
			expect(priority_heap).to be(:valid?)
		end
	end
end
