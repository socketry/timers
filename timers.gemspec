
require_relative 'lib/timers/version'

Gem::Specification.new do |gem|
  gem.name          = "timers"
  gem.version       = Timers::VERSION
  gem.authors       = ["Samuel Williams", "Tony Arcieri"]
  gem.email         = ["samuel@codeotaku.com", "bascule@gmail.com"]
  gem.licenses      = ["MIT"]
  gem.homepage      = "https://github.com/socketry/timers"
  gem.summary       = "Pure Ruby one-shot and periodic timers"
  gem.description = <<-DESCRIPTION.strip.gsub(/\s+/, " ")
    Schedule procs to run after a certain time, or at periodic intervals,
    using any API that accepts a timeout.
  DESCRIPTION

  gem.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "bundler"
end
