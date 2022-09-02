# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016, by Tony Arcieri.
# Copyright, 2018-2021, by Samuel Williams.

require 'timers/group'
require 'timer_quantum'

describe Timers::Group do
	let(:group) {subject.new}
	
	it "should not diverge too much" do
		fired = :not_fired_yet
		count = 0
		quantum = 0.01
		
		start_offset = group.current_offset
		Timers::Timer.new(group, quantum, :strict, start_offset) do |offset|
			fired = offset
			count += 1
		end
		
		iterations = 100
		group.wait while count < iterations
		
		# In my testing on the JVM, without the :strict recurring, I noticed 60ms of error here.
		expect(fired - start_offset).to be_within(quantum + TIMER_QUANTUM).of(iterations * quantum)
	end
	
	it "should only fire 0-interval timer once per iteration" do
		count = 0
		
		start_offset = group.current_offset
		Timers::Timer.new(group, 0, :strict, start_offset) do |offset, timer|
			count += 1
		end
		
		group.wait
		
		expect(count).to be == 1
	end
end
