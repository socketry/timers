
require 'spec_helper'

require 'ruby-prof'

RSpec.describe Timers::Group do
  before(:each) do
    # Running RubyProf makes the code slightly slower.
    RubyProf.start
  end

  after(:each) do |arg|
    if RubyProf.running?
      file = arg.metadata[:description].gsub(/\s+/, '-')
    
      result = RubyProf.stop
    
      printer = RubyProf::FlatPrinter.new(result)
      printer.print($stderr, min_percent: 1.0)
    end
  end
  
  it "run efficiently" do
    result = []
    range = (1..1000)
    duration = 2.0

    total = 0
    range.each do |index|
      offset = index.to_f / range.max
      total += (duration / offset).floor
      
      subject.every(index.to_f / range.max, :strict) { result << index }
    end
    
    subject.wait while result.size < total
    
    rate = result.size.to_f / subject.current_offset
    puts "Serviced #{result.size} events in #{subject.current_offset} seconds, #{rate} e/s."
    
    expect(subject.current_offset).to be_within(TIMER_QUANTUM).of(duration)
  end
end
