# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2016, by Tony Arcieri.
# Copyright, 2018-2021, by Samuel Williams.
# Copyright, 2021, by Wander Hillen.

# Event based timers:

# Serviced 31812 events in 2.39075272 seconds, 13306.320832794887 e/s.
# Thread ID: 7336700
# Fiber ID: 30106340
# Total: 2.384043
# Sort by: self_time

# %self      total      self      wait     child     calls  name
# 13.48      0.510     0.321     0.000     0.189    369133  Timers::Events::Handle#<=>
#  8.12      0.194     0.194     0.000     0.000    427278  Timers::Events::Handle#to_f
#  4.55      0.109     0.109     0.000     0.000    427278  Float#<=>
#  4.40      1.857     0.105     0.000     1.752    466376 *Timers::Events#bsearch
#  4.30      0.103     0.103     0.000     0.000    402945  Float#to_f
#  2.65      0.063     0.063     0.000     0.000     33812  Array#insert
#  2.64      1.850     0.063     0.000     1.787     33812  Timers::Events#schedule
#  2.40      1.930     0.057     0.000     1.873     33812  Timers::Timer#reset
#  1.89      1.894     0.045     0.000     1.849     31812  Timers::Timer#fire
#  1.69      1.966     0.040     0.000     1.926     31812  Timers::Events::Handle#fire
#  1.35      0.040     0.032     0.000     0.008     33812  Timers::Events::Handle#initialize
#  1.29      0.044     0.031     0.000     0.013     44451  Timers::Group#current_offset

# SortedSet based timers:

# Serviced 32516 events in 66.753277275 seconds, 487.1072288781219 e/s.
# Thread ID: 15995640
# Fiber ID: 38731780
# Total: 66.716394
# Sort by: self_time

# %self      total      self      wait     child     calls  name
# 54.73     49.718    36.513     0.000    13.205  57084873  Timers::Timer#<=>
# 23.74     65.559    15.841     0.000    49.718     32534  Array#sort!
# 19.79     13.205    13.205     0.000     0.000  57084873  Float#<=>

# Max out events performance (on my computer):
# Serviced 1142649 events in 11.194903921 seconds, 102068.70405115146 e/s.

require 'timers/group'

describe Timers::Group do
	let(:group) {subject.new}
	
	with "profiler" do
		if defined? RubyProf
			def before
				# Running RubyProf makes the code slightly slower.
				RubyProf.start
				puts "*** Running with RubyProf reduces performance ***"
				
				super
			end
			
			def after
				super
				
				if RubyProf.running?
					# file = arg.metadata[:description].gsub(/\s+/, '-')
					
					result = RubyProf.stop
					
					printer = RubyProf::FlatPrinter.new(result)
					printer.print($stderr, min_percent: 1.0)
				end
			end
		end
		
		it "runs efficiently" do
			result = []
			range = (1..500)
			duration = 2.0
			
			total = 0
			range.each do |index|
				offset = index.to_f / range.max
				total += (duration / offset).floor
				
				group.every(index.to_f / range.max, :strict) { result << index }
			end
			
			group.wait while result.size < total
			
			rate = result.size.to_f / group.current_offset
			inform "Serviced #{result.size} events in #{group.current_offset} seconds, #{rate} e/s."
			
			expect(group.current_offset).to be_within(20).percent_of(duration)
		end
	end
	
	it "runs efficiently at high volume" do
		results = []
		range = (1..300)
		groups = (1..20)
		duration = 2.0
		
		timers = []
		@mutex = Mutex.new
		start = Time.now
		
		groups.each do
			timers << Thread.new do
				result = []
				timer = Timers::Group.new
				total = 0
				
				range.each do |index|
					offset = index.to_f / range.max
					total += (duration / offset).floor
					timer.every(index.to_f / range.max, :strict) { result << index }
				end
				
				timer.wait while result.size < total
				@mutex.synchronize { results += result }
			end
		end
		
		timers.each { |t| t.join }
		finish = Time.now
		
		runtime = finish - start
		rate = results.size.to_f / runtime
		
		inform "Serviced #{results.size} events in #{runtime} seconds, #{rate} e/s; across #{groups.max} timers."
		
		expect(runtime).to be_within(20).percent_of(duration)
	end
	
	it "copes with very large amounts of timers" do
		# This spec tries to emulate (as best as possible) the timer characteristics of the
		# following scenario:
		# - a fairly busy Falcon server serving a constant stream of request that spend most of their time
		#   in a long database call. Both the web request and the db call have a timeout attached
		# - there will already exist a lot of timers in the queue and more are added all the time
		# - the server is assumed to be busy so there are "always" new requests waiting to be accept()-ed
		#   and thus the server spends relatively little time actually sleeping and most of its time in
		#   either the reactor or an active fiber.
		# - On each loop of the reactor it will run any fibers in the ready queue, accept any waiting
		#   requests on the server socket and then call wait_interval to see if there are any expired
		#   timeouts that need to be handled.
		
		# Result for PriorityHeap based timer queue: Inserted 20k timers in 0.055050924 seconds
		# Result for Array based timer queue: 			 Inserted 20k timers in 0.141001845 seconds
		
		results = []
		
		# Prefill the timer queue with a lot of timers in the semidistant future
		20000.times do
			group.after(10) { results << "yay!" }
		end
		
		# add one timer which is done immediately, to get the pending array into the queue
		group.after(-1) { results << "I am first!" }
		group.wait
		expect(results.size).to be == 1
		expect(results.first).to be == "I am first!"
		
		# 20k extra requests come in and get added into the queue
		start = Time.now
		
		20000.times do
			# add new timer to the queue (later than all the others so far)
			group.after(15) { result << "yay again!" }
			# wait_interval in the reactor loop
			group.wait_interval()
		end
		
		expect(group.events.size).to be == 40_000
		puts "Inserted 20k timers in #{Time.now - start} seconds"
	end
end
