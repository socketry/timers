# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2012-2016, by Tony Arcieri.
# Copyright, 2018-2021, by Samuel Williams.

# Level of accuracy enforced by tests:
TIMER_QUANTUM = 0.2

require 'bundler/setup'
Bundler.require(:test)

require 'covered/rspec'

require 'timers'

RSpec.configure do |config|
	# Enable flags like --only-failures and --next-failure
	config.example_status_persistence_file_path = ".rspec_status"
	
	config.expect_with :rspec do |c|
		c.syntax = :expect
	end
end
