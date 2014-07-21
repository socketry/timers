
require 'spec_helper'

RSpec.describe Timers::Events do
  it "should register an event" do
    callback = proc do |time|
    end
    
    handle = subject.schedule(0.1, callback)
    
    expect(subject.sequence.size).to be == 1
    
    popped = subject.pop(1)
    
    expect(subject.sequence.size).to be == 0
    
    expect(popped.first).to be handle
  end
  
  it "should register events in order" do
    callback = proc do |time|
    end
    
    times = [0.95, 0.1, 0.3, 0.5, 0.4, 0.2, 0.01, 0.9]
    
    times.each do |time|
      subject.schedule(time, callback)
    end
    
    sequence_times = subject.sequence.map(&:time)
    expect(times.sort).to be == sequence_times
    
    popped = subject.pop(0.5)
    expect(popped.map(&:time)).to be == times.sort.first(5)
  end
end
