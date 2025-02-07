# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2025, by Samuel Williams.

require "timers/group"

describe Timers::Group do
	let(:group) {subject.new}
	let(:interval) {0.01}
	
	def before
		@fired = false
		@timer = group.after(interval) {@fired = true}
		
		@fired2 = false
		@timer2 = group.after(interval) {@fired2 = true}
		
		super
	end
	
	it "does not fire when paused" do
		@timer.pause
		group.wait
		expect(@fired).to be == false
	end
	
	it "fires when continued after pause" do
		@timer.pause
		group.wait
		@timer.resume
		
		sleep(interval)
		group.wait
		
		expect(@fired).to be == true
	end
	
	it "can pause all timers at once" do
		group.pause
		group.wait
		
		expect(@fired).to be == false
		expect(@fired2).to be == false
	end
	
	it "can continue all timers at once" do
		group.pause
		group.wait
		group.resume
		
		sleep(interval + TIMER_QUANTUM)
		group.wait
		
		expect(@fired).to be == true
		expect(@fired2).to be == true
	end
	
	it "can fire the timer directly" do
		@timer.pause
		
		group.wait
		expect(@fired).not.to be == true
		
		@timer.resume
		expect(@fired).not.to be == true

		@timer.fire
		expect(@fired).to be == true
	end
end
