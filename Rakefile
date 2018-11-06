# frozen_string_literal: true
#
# This file is part of the "timers" project and released under the MIT license.
#
# Copyright, 2018, by Samuel Williams. All rights reserved.
#

require "bundler/gem_tasks"

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new

require "rubocop/rake_task"
RuboCop::RakeTask.new

task default: %w(spec rubocop)
