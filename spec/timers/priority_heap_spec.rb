# frozen_string_literal: true
#
# This file is part of the "timers" project and released under the MIT license.
#

RSpec.describe Timers::PriorityHeap do
  context "when empty" do 
    it "should return nil when the first element is requested" do
      expect(subject.first).to be_nil
    end

    it "should return nil when the first element is extracted" do
      expect(subject.pop).to be_nil
    end

    it "should report its size as zero" do
      expect(subject.size).to be_zero
    end
  end

  it "returns the same element after inserting a single element" do
    subject.insert(1)
    expect(subject.size).to eq(1)
    expect(subject.pop).to eq(1)
    expect(subject.size).to be_zero
  end

  it "should return inserted elements in ascending order no matter the insertion order" do
    (1..10).to_a.shuffle.each do |e|
      subject.insert(e)
    end

    expect(subject.size).to eq(10)

    result = []
    10.times do
      result << subject.pop
    end

    expect(result.size).to eq(10)
    expect(subject.size).to be_zero
    expect(result.sort).to eq(result)
  end
end
