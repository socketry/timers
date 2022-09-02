# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2021, by Wander Hillen.
# Copyright, 2021, by Samuel Williams.

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

  context "maintaining the heap invariant" do
    it "for empty heaps" do
      expect(subject).to be_valid
    end

    it "for heap of size 1" do
      subject.push(123)
      expect(subject).to be_valid
    end
    # Exhaustive testing of all permutations of [1..6]
    it "for all permutations of size 6" do
      [1,2,3,4,5,6].permutation do |arr|
        subject.clear!
        arr.each { |e| subject.push(e) }
        expect(subject).to be_valid
      end
    end

    # A few examples with more elements (but not ALL permutations)
    it "for larger amounts of values" do
      5.times do
        subject.clear!
        (1..1000).to_a.shuffle.each { |e| subject.push(e) }
        expect(subject).to be_valid
      end
    end

    # What if we insert several of the same item along with others?
    it "with several elements of the same value" do
      test_values = (1..10).to_a + [4] * 5
      test_values.each { |e| subject.push(e) }
      expect(subject).to be_valid
    end
  end
end
