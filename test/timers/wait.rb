# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016, by Tony Arcieri.
# Copyright, 2018-2021, by Samuel Williams.

require 'timers/wait'
require 'timer_quantum'

describe Timers::Wait do
	let(:interval) {0.1}
	let(:repeats) {10}
	
	it "repeats until timeout expired" do
		timeout = Timers::Wait.new(interval*repeats)
		count = 0
		
		timeout.while_time_remaining do |remaining|
			expect(remaining).to be_within(TIMER_QUANTUM).of(timeout.duration - (count * interval))
			
			count += 1
			sleep(interval)
		end
		
		expect(count).to be == repeats
	end
	
	it "yields results as soon as possible" do
		timeout = Timers::Wait.new(5)
		
		result = timeout.while_time_remaining do |_remaining|
			break :done
		end
		
		expect(result).to be == :done
	end
end
