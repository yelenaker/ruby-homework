# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'csv_detective'
  s.version     = CSVDetective::VERSION
  s.summary     = 'Detect CSV delimiter, quote char and encoding'
  s.description = 'Small gem that heuristically detects delimiter, quote char and encoding for CSV files'
  s.authors     = ['Your Name']
  s.email       = 'you@example.com'
  s.files       = Dir['lib/**/*'] + ['README.md']
  s.require_paths = ['lib']
  s.homepage    = ''
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.5.0'
end
