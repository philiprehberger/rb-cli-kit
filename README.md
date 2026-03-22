# philiprehberger-cli_kit

[![Tests](https://github.com/philiprehberger/rb-cli-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-cli-kit/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-cli_kit.svg)](https://rubygems.org/gems/philiprehberger-cli_kit)
[![License](https://img.shields.io/github/license/philiprehberger/rb-cli-kit)](LICENSE)

All-in-one CLI toolkit with argument parsing, prompts, and spinners

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-cli_kit"
```

Or install directly:

```bash
gem install philiprehberger-cli_kit
```

## Usage

```ruby
require "philiprehberger/cli_kit"

result = Philiprehberger::CliKit.parse(ARGV) do
  flag :verbose, short: :v
  option :output, short: :o, default: 'out.txt'
end

result.flags[:verbose]    # => true/false
result.options[:output]   # => 'out.txt' or user-provided value
result.arguments          # => remaining positional args
```

### Prompts

```ruby
name = Philiprehberger::CliKit.prompt('What is your name?')
# What is your name? _

confirmed = Philiprehberger::CliKit.confirm('Continue?')
# Continue? [y/n] _
```

### Spinners

```ruby
data = Philiprehberger::CliKit.spinner('Loading data...') do
  # long-running operation
  fetch_remote_data
end
```

### Argument Parsing Details

```ruby
# Given: mytool --verbose -o report.csv input.txt
result = Philiprehberger::CliKit.parse(%w[--verbose -o report.csv input.txt]) do
  flag :verbose, short: :v
  option :output, short: :o, default: 'out.txt'
end

result.flags[:verbose]    # => true
result.options[:output]   # => 'report.csv'
result.arguments          # => ['input.txt']
```

## API

| Method | Description |
|--------|-------------|
| `.parse(args) { ... }` | Parse arguments with flag/option DSL |
| `.prompt(message)` | Display prompt and read input |
| `.confirm(message)` | Display yes/no confirmation |
| `.spinner(message) { ... }` | Show spinner during block execution |
| `Parser#flags` | Hash of boolean flag values |
| `Parser#options` | Hash of option values |
| `Parser#arguments` | Array of positional arguments |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
