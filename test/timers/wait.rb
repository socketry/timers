# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2025, by Samuel Williams.
# Copyright, 2014-2016, by Tony Arcieri.

require "timers/wait"
require "timer_quantum"

describe Timers::Wait do
	let(:interval) {0.1}
	let(:repeats) {10}
	
	it "repeats until timeout expired" do
		timeout = Timers::Wait.new(interval*repeats)
		count = 0
		previous_remaining = nil
		
		timeout.while_time_remaining do |remaining|
			if previous_remaining
				expect(remaining).to be_within(TIMER_QUANTUM).of(previous_remaining - interval)
			end
			
			previous_remaining = remaining
			
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
	
	with "#for" do
		with "no duration" do
			it "waits forever" do
				count = 0
				Timers::Wait.for(nil) do
					count += 1
					break if count > 10
				end
				
				expect(count).to be > 10
			end
		end
	end
end
