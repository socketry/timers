# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2025, by Patrik Wenger.

require 'timers/timer'

describe Timers::Timer do
	let(:group) {Timers::Group.new}
	
	it "should return the block value when fired" do
		timer  = group.after(10) {:foo}
		result = timer.fire

		expect(result).to be == :foo
	end
end
