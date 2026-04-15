# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.1] - 2026-04-15

### Changed
- Compliance audit against Ruby package, gemspec, and README guides — no blocking issues found; reaffirmed gemspec metadata (5 URIs, `rubygems_mfa_required`, `required_ruby_version >= 3.1.0`, `Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']`), README structure (10 sections with 3 badges and emoji Support list), Keep a Changelog format, full `.github/` scaffolding (issue templates, dependabot, PR template, CI matrix with publish job), and config files (`.rubocop.yml`, `.gitignore`, `Gemfile`, `Rakefile`)

## [0.3.0] - 2026-04-15

### Added
- Repeatable options via `option :name, multi: true` — collects each occurrence into an array
- `CliKit.password(message)` — prompt that reads input without echoing when stdin is a TTY (falls back to plain `gets` otherwise)
- `CliKit.ask(message)` — prompt that re-asks until a validator block returns truthy (defaults to any non-empty answer)
- `CliKit.multi_select(message, choices, defaults:)` — numbered menu supporting comma- or space-separated multi-selection
- Help text now shows `VALUE (repeatable)` for `multi: true` options

### Changed
- VERSION spec no longer hardcodes the version string; asserts semver format instead

## [0.2.1] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.2.0] - 2026-03-30

### Added
- Subcommands with isolated flags and options via `command(:name) { ... }` DSL
- `result.command` returns matched subcommand name as symbol or nil
- Auto-generated help text with `desc:` parameter on flags and options
- `--help` / `-h` prints formatted usage and exits
- `result.help_text` returns formatted help string without printing
- `result.help_requested?` indicates whether help was requested
- Menu/selection prompt via `CliKit.select(message, choices)` with numbered options
- `default:` option for pre-selected menu choice
- `input:` and `output:` IO parameters on `select` for testability

## [0.1.2] - 2026-03-22

### Added
- Expand test coverage to 30+ examples with edge cases for unknown flags, multiple flags, default overrides, empty args, positional args between flags, EOF handling

## [0.1.1] - 2026-03-22

### Changed
- Version bump for republishing

## [0.1.0] - 2026-03-22

### Added
- Initial release
- DSL-based argument parser with flags and options
- Short and long option aliases
- Interactive prompt for text input
- Yes/no confirmation prompt
- Animated spinner for long-running operations
- Positional argument collection

[Unreleased]: https://github.com/philiprehberger/rb-cli-kit/compare/v0.3.1...HEAD
[0.3.1]: https://github.com/philiprehberger/rb-cli-kit/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/philiprehberger/rb-cli-kit/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/philiprehberger/rb-cli-kit/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/philiprehberger/rb-cli-kit/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/philiprehberger/rb-cli-kit/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/philiprehberger/rb-cli-kit/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/philiprehberger/rb-cli-kit/releases/tag/v0.1.0
