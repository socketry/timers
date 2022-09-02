# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2014-2022, by Samuel Williams.
# Copyright, 2014-2016, by Tony Arcieri.

require 'timers/events'

describe Timers::Events do
	let(:events) {subject.new}
	
	it "should register an event" do
		fired = false
		
		callback = proc do |_time|
			fired = true
		end
		
		events.schedule(0.1, callback)
		
		expect(events.size).to be == 1
		
		events.fire(0.15)
		
		expect(events.size).to be == 0
		
		expect(fired).to be == true
	end
	
	it "should register events in order" do
		fired = []
		
		times = [0.95, 0.1, 0.3, 0.5, 0.4, 0.2, 0.01, 0.9]
		
		times.each do |requested_time|
			callback = proc do |_time|
				fired << requested_time
			end
			
			events.schedule(requested_time, callback)
		end
		
		events.fire(0.5)
		expect(fired).to be == times.sort.first(6)
		
		events.fire(1.0)
		expect(fired).to be == times.sort
	end
	
	it "should fire events with the time they were fired at" do
		fired_at = :not_fired
		
		callback = proc do |time|
			# The time we actually were fired at:
			fired_at = time
		end
		
		events.schedule(0.5, callback)
		
		events.fire(1.0)
		
		expect(fired_at).to be == 1.0
	end
	
	it "should flush cancelled events" do
		callback = proc{}
		
		10.times do
			handle = events.schedule(0.1, callback)
			handle.cancel!
		end
		
		expect(events.size).to be == 1
	end
end
