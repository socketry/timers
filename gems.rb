# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2020, by Samuel Williams.

source 'https://rubygems.org'

gemspec

group :maintenance, optional: true do
	gem "bake-modernize"
	gem "bake-gem"
end

group :test do
	gem 'benchmark-ips'
	gem "ruby-prof", platform: :mri
end
