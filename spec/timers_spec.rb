require 'spec_helper'

describe Timers do
  # Level of accuracy enforced by tests (50ms)
  Q = 0.05

  it "sleeps until the next timer" do
    interval   = Q * 2
    started_at = Time.now

    fired = false
    subject.after(interval) { fired = true }
    subject.wait

    expect(fired).to be_true
    expect(Time.now - started_at).to be_within(Q).of interval
  end

  it "fires instantly when next timer is in the past" do
    fired = false
    subject.after(Q) { fired = true }
    sleep(Q * 2)
    subject.wait

    expect(fired).to be_true
  end

  it "calculates the interval until the next timer should fire" do
    interval = 0.1

    subject.after(interval)
    expect(subject.wait_interval).to be_within(Q).of interval

    sleep(interval)
    expect(subject.wait_interval).to be(0)
  end

  it "fires timers in the correct order" do
    result = []

    subject.after(Q * 2) { result << :two }
    subject.after(Q * 3) { result << :three }
    subject.after(Q * 1) { result << :one }

    sleep Q * 4
    subject.fire

    expect(result).to eq [:one, :two, :three]
  end

  it "raises TypeError if given an invalid time" do
    expect do
      subject.after(nil) { nil }
    end.to raise_exception(TypeError)
  end

  describe "recurring timers" do
    it "continues to fire the timers at each interval" do
      result = []

      subject.every(Q * 2) { result << :foo }

      sleep Q * 3
      subject.fire
      expect(result).to eq [:foo]

      sleep Q * 5
      subject.fire
      expect(result).to eq [:foo, :foo]
    end
  end

  describe "millisecond timers" do
    it "calculates the proper interval to wait until firing" do
      interval_ms = 25

      subject.after_milliseconds(interval_ms)
      expected_elapse = subject.wait_interval

      expect(subject.wait_interval).to be_within(Q).of(interval_ms / 1000.0)
    end
  end

  describe "pause and continue timers" do
    before(:each) do
      @interval   = Q * 2
      started_at = Time.now

      @fired = false
      @timer = subject.every(@interval) { @fired = true }
      @fired2 = false
      @timer2 = subject.every(@interval) { @fired2 = true }
    end

    it "does not fire when paused" do
      @timer.pause
      subject.wait
      expect(@fired).to be_false
    end

    it "fires when continued after pause" do
      @timer.pause
      subject.wait
      @timer.continue
      subject.wait
      expect(@fired).to be_true
    end

    it "can pause all timers at once" do
      subject.pause
      subject.wait
      expect(@fired).to be_false
      expect(@fired2).to be_false
    end

    it "can continue all timers at once" do
      subject.pause
      subject.wait
      subject.continue
      subject.wait
      expect(@fired).to be_true
      expect(@fired2).to be_true
    end

    it "can fire the timer directly" do
      fired = false
      timer = subject.after( Q * 1 ) { fired = true }
      timer.pause
      subject.wait
      expect(fired).not_to be_true
      timer.continue
      expect(fired).not_to be_true
      timer.fire
      expect(fired).to be_true
    end

  end

  describe "delay timer" do
    it "adds appropriate amount of time to timer" do
      timer = subject.after(10)
      timer.delay(5)
      expect(timer.offset - subject.current_offset).to be_within(Q).of(15)
    end
  end

  describe "delay timer collection" do
    it "delay on set adds appropriate amount of time to all timers" do
      timer = subject.after(10)
      timer2 = subject.after(20)
      subject.delay(5)
      expect(timer.offset - subject.current_offset).to be_within(Q).of(15)
      expect(timer2.offset - subject.current_offset).to be_within(Q).of(25)
    end
  end

  describe "on delaying a timer" do
    it "fires timers in the correct order" do
      result = []

      second = subject.after(Q * 2) { result << :two }
      third = subject.after(Q * 3) { result << :three }
      first = subject.after(Q * 1) { result << :one }
      first.delay(Q * 3)

      sleep Q * 5
      subject.fire

      expect(result).to eq [:two, :three, :one]
    end
  end

  describe "Timer inspection" do
    it "before firing" do
      fired = false
      timer = subject.after(Q * 5) { fired = true }
      timer.pause
      expect(fired).not_to be_true
      expect(timer.inspect).to match(/\A#<Timers::Timer:[\da-f]+ fires in [-\.\de]+ seconds>\Z/)
    end

    it "after firing" do
      fired = false
      timer = subject.after(Q) { fired = true }

      subject.wait

      expect(fired).to be_true
      expect(timer.inspect).to match(/\A#<Timers::Timer:[\da-f]+ fired [-\.\de]+ seconds ago>\Z/)
    end

    it "recurring firing" do
      result = []
      timer = subject.every(Q) { result << :foo }

      subject.wait
      expect(result).not_to be_empty
      expect(timer.inspect).to match(/\A#<Timers::Timer:[\da-f]+ fires in [-\.\de]+ seconds, recurs every #{sprintf("%0.2f", Q)}>\Z/)
    end
  end
end
