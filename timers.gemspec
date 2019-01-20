# frozen_string_literal: true
#
# This file is part of the "timers" project and released under the MIT license.
#
# Copyright, 2018, by Samuel Williams. All rights reserved.
#

require_relative 'lib/timers/version'

Gem::Specification.new do |spec|
	spec.name          = "timers"
	spec.version       = Timers::VERSION
	spec.authors       = ["Samuel Williams", "Tony Arcieri"]
	spec.email         = ["samuel@codeotaku.com", "bascule@gmail.com"]
	spec.licenses      = ["MIT"]
	spec.homepage      = "https://github.com/socketry/timers"
	spec.summary       = "Pure Ruby one-shot and periodic timers"
	spec.description = <<-DESCRIPTION.strip.gsub(/\s+/, " ")
		Schedule procs to run after a certain time, or at periodic intervals,
		using any API that accepts a timeout.
	DESCRIPTION

	spec.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
	spec.executables   = spec.files.grep(%r{^bin/}).map { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]

	spec.required_ruby_version = '>= 2.2.1'

	spec.add_development_dependency "bundler"
	spec.add_development_dependency "rspec", "~> 3.6"
	spec.add_development_dependency "rake"
end
