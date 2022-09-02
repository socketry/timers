# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022, by Samuel Williams.

require 'timers/group'
require 'timer_quantum'

describe Timers::Group do
	let(:group) {subject.new}
	
	with "#wait" do
		it "calls the wait block with nil" do
			called = false
			
			group.wait do |interval|
				expect(interval).to be_nil
				called = true
			end
			
			expect(called).to be == true
		end
		
		it "calls the wait block with an interval" do
			called = false
			fired = false
			
			group.after(0.1) { fired = true }
			
			group.wait do |interval|
				expect(interval).to be_within(TIMER_QUANTUM).of(0.1)
				called = true
				sleep 0.2
			end
			
			expect(called).to be == true
			expect(fired).to be == true
		end
	end
	
	it "sleeps until the next timer" do
		interval = 0.1
		started_at = Time.now
		
		fired = false
		group.after(interval) {fired = true}
		group.wait
		
		expect(fired).to be == true
		expect(Time.now - started_at).to be_within(TIMER_QUANTUM).of(interval)
	end
	
	it "fires instantly when next timer is in the past" do
		fired = false
		group.after(TIMER_QUANTUM) { fired = true }
		sleep(TIMER_QUANTUM * 2)
		group.wait
		
		expect(fired).to be == true
	end
	
	it "calculates the interval until the next timer should fire" do
		interval = 0.1
		
		group.after(interval)
		expect(group.wait_interval).to be_within(TIMER_QUANTUM).of interval
		
		sleep(interval)
		expect(group.wait_interval).to be <= 0
	end
	
	it "fires timers in the correct order" do
		result = []
		
		group.after(TIMER_QUANTUM * 2) { result << :two }
		group.after(TIMER_QUANTUM * 3) { result << :three }
		group.after(TIMER_QUANTUM * 1) { result << :one }
		
		sleep(TIMER_QUANTUM * 4)
		group.fire
		
		expect(result).to be == [:one, :two, :three]
	end
	
	it "raises TypeError if given an invalid time" do
		expect do
			group.after(nil) { nil }
		end.to raise_exception(TypeError)
	end
	
	with "recurring timers" do
		it "continues to fire the timers at each interval" do
			result = []
			
			group.every(TIMER_QUANTUM * 2) { result << :foo }
			
			sleep TIMER_QUANTUM * 3
			group.fire
			expect(result).to be == [:foo]
			
			sleep TIMER_QUANTUM * 5
			group.fire
			expect(result).to be == [:foo, :foo]
		end
	end
	
	it "calculates the proper interval to wait until firing" do
		interval_ms = 25
		
		group.after(interval_ms / 1000.0)
		
		expect(group.wait_interval).to be_within(TIMER_QUANTUM).of(interval_ms / 1000.0)
	end
	
	with "delay timer" do
		it "adds appropriate amount of time to timer" do
			timer = group.after(10)
			timer.delay(5)
			expect(timer.offset - group.current_offset).to be_within(TIMER_QUANTUM).of(15)
		end
	end
	
	with "delay timer collection" do
		it "delay on set adds appropriate amount of time to all timers" do
			timer = group.after(10)
			timer2 = group.after(20)
			group.delay(5)
			expect(timer.offset - group.current_offset).to be_within(TIMER_QUANTUM).of(15)
			expect(timer2.offset - group.current_offset).to be_within(TIMER_QUANTUM).of(25)
		end
	end
	
	with "on delaying a timer" do
		it "fires timers in the correct order" do
			result = []
			
			group.after(TIMER_QUANTUM * 2) { result << :two }
			group.after(TIMER_QUANTUM * 3) { result << :three }
			first = group.after(TIMER_QUANTUM * 1) { result << :one }
			first.delay(TIMER_QUANTUM * 3)
			
			sleep TIMER_QUANTUM * 5
			group.fire
			
			expect(result).to be == [:two, :three, :one]
		end
	end
	
	with "#inspect" do
		it "before firing" do
			fired = false
			timer = group.after(TIMER_QUANTUM * 5) { fired = true }
			timer.pause
			expect(fired).not.to be == true
			expect(timer.inspect).to be =~ /\A#<Timers::Timer:0x[\da-f]+ fires in [-\.\de]+ seconds>\Z/
		end
		
		it "after firing" do
			fired = false
			timer = group.after(TIMER_QUANTUM) { fired = true }
			
			group.wait
			
			expect(fired).to be == true
			expect(timer.inspect).to be =~/\A#<Timers::Timer:0x[\da-f]+ fired [-\.\de]+ seconds ago>\Z/
		end
		
		it "recurring firing" do
			result = []
			timer = group.every(TIMER_QUANTUM) { result << :foo }
			
			group.wait
			expect(result).to be(:any?)
			regex = /\A#<Timers::Timer:0x[\da-f]+ fires in [-\.\de]+ seconds, recurs every #{TIMER_QUANTUM}>\Z/
			expect(timer.inspect).to be =~ regex
		end
	end
	
	with "#fires_in" do
		let(:interval) {0.01}
		
		with "recurring timer" do
			let(:timer) {group.every(interval){true}}

			it "calculates the interval until the next fire if it's recurring" do
				expect(timer.fires_in).to be_within(TIMER_QUANTUM).of(interval)
			end
		end
		
		with "non-recurring timer" do
			let(:timer) {group.after(interval){true}}
			
			it "calculates the interval until the next fire if it hasn't already fired" do
				expect(timer.fires_in).to be_within(TIMER_QUANTUM).of(interval)
			end
			
			it "calculates the interval since last fire if already fired" do
				# Create the timer:
				timer
				
				group.wait
				
				sleep(TIMER_QUANTUM)
				
				expect(timer.fires_in).to be < 0.0
			end
		end
	end
end
