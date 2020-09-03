
require_relative "lib/timers/version"

Gem::Specification.new do |spec|
	spec.name = "timers"
	spec.version = Timers::VERSION
	
	spec.summary = "Pure Ruby one-shot and periodic timers."
	spec.authors = ["Samuel Williams", "Tony Arcieri"]
	spec.license = "MIT"
	
	spec.homepage = "https://github.com/socketry/timers"
	
	spec.files = Dir.glob('{lib}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 2.5"
	
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered"
	spec.add_development_dependency "rspec", "~> 3.0"
end
