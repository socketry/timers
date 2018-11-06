source 'https://rubygems.org'

gemspec

group :development do
	gem 'pry'
end

group :test do
	gem 'benchmark-ips'
	gem "ruby-prof" unless RUBY_PLATFORM =~ /java|rbx/
	
	gem 'simplecov'
	gem 'coveralls'
end
