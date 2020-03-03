# philiprehberger-cli_kit

[![Tests](https://github.com/philiprehberger/rb-cli-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-cli-kit/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-cli_kit.svg)](https://rubygems.org/gems/philiprehberger-cli_kit)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-cli-kit)](https://github.com/philiprehberger/rb-cli-kit/commits/main)

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

### Subcommands

```ruby
result = Philiprehberger::CliKit.parse(ARGV) do
  command(:deploy) do
    flag :force, short: :f
    option :env, short: :e
  end
  command(:test) do
    flag :coverage
  end
end

result.command            # => :deploy or :test or nil
result.flags[:force]      # => true/false (within matched command)
result.options[:env]      # => user-provided value
```

### Auto-generated Help

```ruby
result = Philiprehberger::CliKit.parse(ARGV) do
  flag :verbose, short: :v, desc: 'Enable verbose output'
  option :output, short: :o, desc: 'Output file path'
end

# Passing --help or -h prints formatted usage and exits:
#   Usage: command [options]
#
#   Options:
#     -v, --verbose           Enable verbose output
#     -o, --output VALUE      Output file path

result.help_text          # => formatted help string without printing
```

### Prompts

```ruby
name = Philiprehberger::CliKit.prompt('What is your name?')
# What is your name? _

confirmed = Philiprehberger::CliKit.confirm('Continue?')
# Continue? [y/n] _
```

### Menu Selection

```ruby
env = Philiprehberger::CliKit.select('Choose env:', %w[dev staging prod])
#   Choose env:
#     1) dev
#     2) staging
#     3) prod
#   Choose: _

env = Philiprehberger::CliKit.select('Choose env:', %w[dev staging prod], default: 'staging')
#   Choose env:
#       1) dev
#     * 2) staging
#       3) prod
#   Choose [2]: _
```

### Spinners

```ruby
data = Philiprehberger::CliKit.spinner('Loading data...') do
  # long-running operation
  fetch_remote_data
end
```

## API

| Method | Description |
|--------|-------------|
| `.parse(args) { ... }` | Parse arguments with flag/option/command DSL |
| `.prompt(message)` | Display prompt and read input |
| `.confirm(message)` | Display yes/no confirmation |
| `.select(message, choices)` | Present numbered menu and return selection |
| `.spinner(message) { ... }` | Show spinner during block execution |
| `Parser#flags` | Hash of boolean flag values |
| `Parser#options` | Hash of option values |
| `Parser#arguments` | Array of positional arguments |
| `Parser#command` | Matched subcommand name or nil |
| `Parser#help_text` | Formatted help string |
| `Parser#help_requested?` | Whether --help or -h was passed |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-cli-kit)

🐛 [Report issues](https://github.com/philiprehberger/rb-cli-kit/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-cli-kit/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
