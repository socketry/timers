# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2022, by Samuel Williams.
# Copyright, 2014-2016, by Tony Arcieri.
# Copyright, 2015, by Tommy Ong Gia Phu.
# Copyright, 2015, by Donovan Keme.

require 'timers/group'

describe Timers::Group do
	let(:group) {subject.new}
	
	it "should fire several times" do
		result = []
		
		group.every(0.7) { result << :a }
		group.every(2.3) { result << :b }
		group.every(1.3) { result << :c }
		group.every(2.4) { result << :d }
		
		Timers::Wait.for(2.5) do |remaining|
			group.wait if group.wait_interval < remaining
		end
		
		expect(result).to be == [:a, :c, :a, :a, :b, :d]
	end
	
	it "should fire immediately and then several times later" do
		result = []
		
		group.every(0.7) { result << :a }
		group.every(2.3) { result << :b }
		group.now_and_every(1.3) { result << :c }
		group.now_and_every(2.4) { result << :d }
		
		Timers::Wait.for(2.5) do |remaining|
			group.wait if group.wait_interval < remaining
		end
		
		expect(result).to be == [:c, :d, :a, :c, :a, :a, :b, :d]
	end
end
