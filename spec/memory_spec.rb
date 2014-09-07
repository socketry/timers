
require 'spec_helper'

RSpec.describe Timers::Group do
  describe "cancelling timers" do
    it "should cancel one shot timers after they fire" do
      x = 0

      Timers::Wait.for(2) do |remaining|
        timer = subject.every(0.2) { x += 1 }
        subject.after(0.1) { timer.cancel }
        
        subject.wait
      end
      
      GC.start
      
      expect(ObjectSpace.each_object(Timers::Timer).to_a).to be_empty
      expect(x).to be == 0
    end
  end
end
