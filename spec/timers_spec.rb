require 'spec_helper'

describe Timers do
  # Level of accuracy enforced by the tests (50ms)
  Q = 0.05

  it "sleeps until the next timer" do
    interval   = Q * 2
    started_at = Time.now

    fired = false
    subject.after(interval) { fired = true }
    subject.wait

    fired.should be_true
    (Time.now - started_at).should be_within(Q).of interval
  end

  it "calculates the interval until the next timer should fire" do
    interval = 0.1

    subject.after(interval)
    subject.wait_interval.should be_within(Q).of interval
  end

  it "fires timers in the correct order" do
    result = []

    subject.after(Q * 2) { result << :two }
    subject.after(Q * 3) { result << :three }
    subject.after(Q * 1) { result << :one }

    sleep Q * 4
    subject.fire

    result.should == [:one, :two, :three]
  end

  describe "recurring timers" do
    it "continues to fire the timers at each interval" do
      result = []

      subject.every(Q * 2) { result << :foo }

      sleep Q * 3
      subject.fire
      result.should == [:foo]

      sleep Q * 5
      subject.fire
      result.should == [:foo, :foo]
    end
  end
end
