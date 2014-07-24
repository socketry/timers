
require 'spec_helper'

RSpec.describe Timers::Events do
  it "should register an event" do
    fired = false
    
    callback = proc do |time|
      fired = true
    end
    
    handle = subject.schedule(0.1, callback)
    
    expect(subject.size).to be == 1
    
    subject.fire(0.15)
    
    expect(subject.size).to be == 0
    
    expect(fired).to be true
  end
  
  it "should register events in order" do
    fired = []
    
    callback = proc do |time|
      fired << time
    end
    
    times = [0.95, 0.1, 0.3, 0.5, 0.4, 0.2, 0.01, 0.9]
    
    times.each do |time|
      subject.schedule(time, callback)
    end
    
    subject.fire(0.5)
    expect(fired).to be == times.sort.first(6)
    
    subject.fire(1.0)
    expect(fired).to be == times.sort
  end
end
