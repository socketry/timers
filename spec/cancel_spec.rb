
require 'spec_helper'

RSpec.describe Timers::Group do
  it "should be able to cancel twice" do
    fired = false

    timer = subject.after(0.1) { fired = true }
    
    2.times do
      timer.cancel
      subject.wait
    end

    expect(fired).to be false
  end
  
  it "should be possble to reset after cancel" do
    fired = false
    
    timer = subject.after(0.1) { fired = true }
    timer.cancel
    
    subject.wait
    
    timer.reset
    
    subject.wait
    
    expect(fired).to be true
  end
end
