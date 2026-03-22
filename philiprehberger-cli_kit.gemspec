# frozen_string_literal: true

require_relative 'lib/philiprehberger/cli_kit/version'

Gem::Specification.new do |spec|
  spec.name          = 'philiprehberger-cli_kit'
  spec.version       = Philiprehberger::CliKit::VERSION
  spec.authors       = ['Philip Rehberger']
  spec.email         = ['me@philiprehberger.com']

  spec.summary       = 'All-in-one CLI toolkit with argument parsing, prompts, and spinners'
  spec.description   = 'Lightweight CLI toolkit combining argument parsing with flags and options, ' \
                       'interactive prompts with confirmation, and animated spinners for long-running operations.'
  spec.homepage      = 'https://github.com/philiprehberger/rb-cli-kit'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri']          = spec.homepage
  spec.metadata['source_code_uri']       = spec.homepage
  spec.metadata['changelog_uri']         = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri']       = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
