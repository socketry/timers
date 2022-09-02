
class TimerQuantum
	def self.resolve
		self.new.to_f
	end
	
	def to_f
		precision
	end
	
	private
	
	def precision
		@precision ||= self.measure_host_precision
	end
	
	def measure_host_precision(repeats: 1000, duration: 0.000001)
		# Measure the precision sleep using the monotonic clock:
		start_time = self.now
		repeats.times do
			sleep(duration)
		end
		end_time = self.now
		
		return (end_time - start_time) - (repeats * duration)
	end
	
	def now
		Process.clock_gettime(Process::CLOCK_MONOTONIC)
	end
end

TIMER_QUANTUM = TimerQuantum.resolve
