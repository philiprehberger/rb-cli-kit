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

### Password Prompt

```ruby
secret = Philiprehberger::CliKit.password('Enter password:')
# Enter password: _
# Input is read without echoing to the terminal when stdin is a TTY.
```

### Validated Ask

```ruby
# Without a block, any non-empty answer is accepted.
name = Philiprehberger::CliKit.ask('Name:')

# With a block, the prompt repeats until the block returns a truthy value.
port = Philiprehberger::CliKit.ask('Port:', error: 'Must be a number') do |answer|
  answer.match?(/\A\d+\z/)
end
```

### Required options

```ruby
result = Philiprehberger::CliKit.parse(ARGV) do
  option :env, short: :e, required: true, desc: 'Target environment'
end

# Invoked without --env raises Philiprehberger::CliKit::Error:
#   Missing required option(s): --env
#
# Help text appends "(required)" to the option's description:
#   -e, --env VALUE     Target environment (required)
```

### Repeatable Options

```ruby
result = Philiprehberger::CliKit.parse(ARGV) do
  option :tag, short: :t, multi: true, desc: 'Add a tag (repeatable)'
end

# Invoked as: mycli --tag ruby --tag cli -t kit
result.options[:tag]   # => ["ruby", "cli", "kit"]
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

### Multi-Select Menu

```ruby
tags = Philiprehberger::CliKit.multi_select('Pick tags:', %w[ruby cli dsl testing])
#   Pick tags:
#       1) ruby
#       2) cli
#       3) dsl
#       4) testing
#   Choose (comma-separated): 1,3
# => ["ruby", "dsl"]

tags = Philiprehberger::CliKit.multi_select('Pick tags:', %w[ruby cli dsl], defaults: %w[ruby dsl])
#   Pick tags:
#     * 1) ruby
#       2) cli
#     * 3) dsl
#   Choose (comma-separated): _   # empty answer => defaults
```

### Spinners

```ruby
data = Philiprehberger::CliKit.spinner('Loading data...') do
  # long-running operation
  fetch_remote_data
end
```

### Color Output

Colors are auto-disabled when stdout is not a TTY or the `NO_COLOR` environment variable is set.

```ruby
require "philiprehberger/cli_kit"

puts Philiprehberger::CliKit.color('OK', :green)
puts Philiprehberger::CliKit.bold('Important')
```

## API

| Method | Description |
|--------|-------------|
| `.parse(args) { ... }` | Parse arguments with flag/option/command DSL |
| `.prompt(message)` | Display prompt and read input |
| `.confirm(message)` | Display yes/no confirmation |
| `.password(message)` | Read input without echoing to the terminal |
| `.ask(message) { \|answer\| ... }` | Prompt until block returns truthy (defaults to non-empty) |
| `.select(message, choices)` | Present numbered menu and return one selection |
| `.multi_select(message, choices, defaults:)` | Present numbered menu and return multiple selections |
| `.spinner(message) { ... }` | Show spinner during block execution |
| `.color(text, name)` | Wrap text in ANSI color (no-op when not a TTY or NO_COLOR set) |
| `.bold(text)` | Wrap text in ANSI bold |
| `.dim(text)` | Wrap text in ANSI dim |
| `Parser#option(name, multi: true)` | Collect repeated option values into an array |
| `Parser#option(name, required: true)` | Raise `CliKit::Error` at parse time when the option is omitted |
| `Parser#flags` | Hash of boolean flag values |
| `Parser#options` | Hash of option values (arrays when `multi: true`) |
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
