# frozen_string_literal: true
#
# This file is part of the "timers" project and released under the MIT license.
#
# Copyright, 2018, by Samuel Williams. All rights reserved.
#

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
