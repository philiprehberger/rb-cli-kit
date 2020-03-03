# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
