# frozen_string_literal: true

require_relative "lib/timers/version"

Gem::Specification.new do |spec|
	spec.name = "timers"
	spec.version = Timers::VERSION
	
	spec.summary = "Pure Ruby one-shot and periodic timers."
	spec.authors = ["Tony Arcieri", "Samuel Williams", "Donovan Keme", "Wander Hillen", "Utenmiki", "Jeremy Hinegardner", "Sean Gregory", "Chuck Remes", "Olle Jonsson", "Ron Evans", "Tommy Ong Gia Phu", "Larry Lv", "Lin Jen-Shin", "Ryunosuke SATO", "Atul Bhosale", "Bruno Enten", "Dimitrij Denissenko", "Feram", "Jesse Cooke", "Klaus Trainer", "Lavir the Whiolet", "Mike Bourgeous", "Nicholas Evans", "Peter Goldstein", "Ryan LeCompte", "Tim Smith", "Vít Ondruch", "Will Jessop", "Yoshiki Takagi"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/socketry/timers"
	
	spec.files = Dir.glob(['{lib}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.add_development_dependency "bake-test", "~> 0.1"
	spec.add_development_dependency "bake-test-external", "~> 0.2"
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered"
	spec.add_development_dependency "sus", "~> 0.13"
end
