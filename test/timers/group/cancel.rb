# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014, by Lin Jen-Shin.
# Copyright, 2014-2016, by Tony Arcieri.
# Copyright, 2014-2022, by Samuel Williams.

require 'timers/group'

describe Timers::Group do
	let(:group) {subject.new}
	
	it "should be able to cancel twice" do
		fired = false
		
		timer = group.after(0.1) { fired = true }
		
		2.times do
			timer.cancel
			group.wait
		end
		
		expect(fired).to be == false
	end
	
	it "should be possble to reset after cancel" do
		fired = false
		
		timer = group.after(0.1) { fired = true }
		timer.cancel
		
		group.wait
		
		timer.reset
		
		group.wait
		
		expect(fired).to be == true
	end
	
	it "should cancel and remove one shot timers after they fire" do
		x = 0
		
		Timers::Wait.for(2) do |_remaining|
			timer = group.every(0.2) { x += 1 }
			group.after(0.1) { timer.cancel }
			
			group.wait
		end
		
		expect(group.timers).to be(:empty?)
		expect(x).to be == 0
	end
end
