source 'https://rubygems.org'

gemspec

group :development do
	gem 'pry'
end

group :test do
	gem 'benchmark-ips'
	gem 'ruby-prof', platforms: :mri
	
	gem 'simplecov'
	gem 'coveralls', require: false
end

gem "ruby-prof", group: :test unless RUBY_PLATFORM =~ /java|rbx/
