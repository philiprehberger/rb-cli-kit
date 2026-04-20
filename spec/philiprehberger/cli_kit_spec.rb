# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Philiprehberger::CliKit do
  describe 'VERSION' do
    it 'has a version number' do
      expect(Philiprehberger::CliKit::VERSION).not_to be_nil
    end

    it 'matches semantic versioning' do
      expect(Philiprehberger::CliKit::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
    end
  end

  describe '.parse' do
    it 'parses long flags' do
      result = described_class.parse(%w[--verbose]) do
        flag :verbose
      end

      expect(result.flags[:verbose]).to be true
    end

    it 'defaults flags to false' do
      result = described_class.parse([]) do
        flag :verbose
      end

      expect(result.flags[:verbose]).to be false
    end

    it 'parses short flags' do
      result = described_class.parse(%w[-v]) do
        flag :verbose, short: :v
      end

      expect(result.flags[:verbose]).to be true
    end

    it 'parses long options' do
      result = described_class.parse(%w[--output report.csv]) do
        option :output
      end

      expect(result.options[:output]).to eq('report.csv')
    end

    it 'parses short options' do
      result = described_class.parse(%w[-o report.csv]) do
        option :output, short: :o
      end

      expect(result.options[:output]).to eq('report.csv')
    end

    it 'uses default option values' do
      result = described_class.parse([]) do
        option :output, default: 'out.txt'
      end

      expect(result.options[:output]).to eq('out.txt')
    end

    it 'collects positional arguments' do
      result = described_class.parse(%w[file1.txt file2.txt]) do
        flag :verbose
      end

      expect(result.arguments).to eq(%w[file1.txt file2.txt])
    end

    it 'handles mixed flags, options, and arguments' do
      result = described_class.parse(%w[--verbose -o out.csv input.txt extra.txt]) do
        flag :verbose, short: :v
        option :output, short: :o, default: 'out.txt'
      end

      expect(result.flags[:verbose]).to be true
      expect(result.options[:output]).to eq('out.csv')
      expect(result.arguments).to eq(%w[input.txt extra.txt])
    end

    it 'handles hyphened long options' do
      result = described_class.parse(%w[--dry-run]) do
        flag :dry_run
      end

      expect(result.flags[:dry_run]).to be true
    end

    it 'returns self from parse for chaining' do
      result = described_class.parse([]) do
        flag :verbose
      end
      expect(result).to be_a(Philiprehberger::CliKit::Parser)
    end

    it 'handles multiple flags at once' do
      result = described_class.parse(%w[--verbose --debug --force]) do
        flag :verbose
        flag :debug
        flag :force
      end

      expect(result.flags[:verbose]).to be true
      expect(result.flags[:debug]).to be true
      expect(result.flags[:force]).to be true
    end

    it 'ignores unknown long flags' do
      result = described_class.parse(%w[--unknown]) do
        flag :verbose
      end

      expect(result.flags[:verbose]).to be false
      expect(result.arguments).to be_empty
    end

    it 'ignores unknown short flags' do
      result = described_class.parse(%w[-x]) do
        flag :verbose, short: :v
      end

      expect(result.flags[:verbose]).to be false
    end

    it 'handles multiple options with defaults' do
      result = described_class.parse([]) do
        option :host, default: 'localhost'
        option :port, default: '8080'
      end

      expect(result.options[:host]).to eq('localhost')
      expect(result.options[:port]).to eq('8080')
    end

    it 'overrides defaults when option is provided' do
      result = described_class.parse(%w[--host 0.0.0.0]) do
        option :host, default: 'localhost'
      end

      expect(result.options[:host]).to eq('0.0.0.0')
    end

    it 'handles options with nil default' do
      result = described_class.parse([]) do
        option :config
      end

      expect(result.options[:config]).to be_nil
    end

    it 'parses empty args with no definitions' do
      result = described_class.parse([]) {}
      expect(result.flags).to eq({})
      expect(result.options).to eq({})
      expect(result.arguments).to eq([])
    end

    it 'collects multiple positional arguments between flags' do
      result = described_class.parse(%w[file1.txt --verbose file2.txt]) do
        flag :verbose
      end

      expect(result.flags[:verbose]).to be true
      expect(result.arguments).to eq(%w[file1.txt file2.txt])
    end
  end

  describe 'subcommands' do
    it 'parses a subcommand with its own flags' do
      result = described_class.parse(%w[deploy --force]) do
        command(:deploy) do
          flag :force, short: :f
        end
      end

      expect(result.command).to eq(:deploy)
      expect(result.flags[:force]).to be true
    end

    it 'parses a subcommand with its own options' do
      result = described_class.parse(%w[deploy --env staging]) do
        command(:deploy) do
          option :env, short: :e
        end
      end

      expect(result.command).to eq(:deploy)
      expect(result.options[:env]).to eq('staging')
    end

    it 'parses subcommand with short flags' do
      result = described_class.parse(%w[deploy -f -e production]) do
        command(:deploy) do
          flag :force, short: :f
          option :env, short: :e
        end
      end

      expect(result.command).to eq(:deploy)
      expect(result.flags[:force]).to be true
      expect(result.options[:env]).to eq('production')
    end

    it 'returns nil command when no command matches' do
      result = described_class.parse(%w[--verbose]) do
        flag :verbose
        command(:deploy) do
          flag :force
        end
      end

      expect(result.command).to be_nil
      expect(result.flags[:verbose]).to be true
    end

    it 'collects positional arguments after subcommand' do
      result = described_class.parse(%w[deploy app1 app2]) do
        command(:deploy) do
          flag :force
        end
      end

      expect(result.command).to eq(:deploy)
      expect(result.arguments).to eq(%w[app1 app2])
    end

    it 'isolates command flags from top-level flags' do
      result = described_class.parse(%w[deploy --force]) do
        flag :verbose
        command(:deploy) do
          flag :force
        end
      end

      expect(result.command).to eq(:deploy)
      expect(result.flags[:force]).to be true
      expect(result.flags).not_to have_key(:verbose)
    end

    it 'supports multiple command definitions' do
      result = described_class.parse(%w[test --coverage]) do
        command(:deploy) do
          flag :force
        end
        command(:test) do
          flag :coverage
        end
      end

      expect(result.command).to eq(:test)
      expect(result.flags[:coverage]).to be true
    end

    it 'parses subcommand with mixed flags, options, and arguments' do
      result = described_class.parse(%w[deploy -f --env staging app.rb]) do
        command(:deploy) do
          flag :force, short: :f
          option :env, short: :e
        end
      end

      expect(result.command).to eq(:deploy)
      expect(result.flags[:force]).to be true
      expect(result.options[:env]).to eq('staging')
      expect(result.arguments).to eq(%w[app.rb])
    end

    it 'uses default option values in subcommands' do
      result = described_class.parse(%w[deploy]) do
        command(:deploy) do
          option :env, default: 'development'
        end
      end

      expect(result.command).to eq(:deploy)
      expect(result.options[:env]).to eq('development')
    end
  end

  describe 'auto-generated help' do
    it 'generates help text for flags with descriptions' do
      parser = Philiprehberger::CliKit::Parser.new
      parser.flag(:verbose, short: :v, desc: 'Enable verbose output')
      parser.flag(:force, desc: 'Force operation')

      help = parser.help_text
      expect(help).to include('-v, --verbose')
      expect(help).to include('Enable verbose output')
      expect(help).to include('--force')
      expect(help).to include('Force operation')
    end

    it 'generates help text for options with descriptions' do
      parser = Philiprehberger::CliKit::Parser.new
      parser.option(:output, short: :o, desc: 'Output file path')

      help = parser.help_text
      expect(help).to include('-o, --output VALUE')
      expect(help).to include('Output file path')
    end

    it 'formats flags without short alias correctly' do
      parser = Philiprehberger::CliKit::Parser.new
      parser.flag(:verbose, desc: 'Enable verbose output')

      help = parser.help_text
      expect(help).to include('--verbose')
      expect(help).to include('Enable verbose output')
    end

    it 'formats options without short alias correctly' do
      parser = Philiprehberger::CliKit::Parser.new
      parser.option(:config, desc: 'Config file path')

      help = parser.help_text
      expect(help).to include('--config VALUE')
      expect(help).to include('Config file path')
    end

    it 'includes commands section when commands are defined' do
      parser = Philiprehberger::CliKit::Parser.new
      parser.command(:deploy) { flag :force }
      parser.command(:test) { flag :coverage }

      help = parser.help_text
      expect(help).to include('Commands:')
      expect(help).to include('deploy')
      expect(help).to include('test')
    end

    it 'sets help_requested? when --help is passed' do
      parser = Philiprehberger::CliKit::Parser.new
      parser.flag(:verbose)
      parser.parse(%w[--help])

      expect(parser.help_requested?).to be true
    end

    it 'sets help_requested? when -h is passed' do
      parser = Philiprehberger::CliKit::Parser.new
      parser.flag(:verbose)
      parser.parse(%w[-h])

      expect(parser.help_requested?).to be true
    end

    it 'does not set help_requested? for normal args' do
      parser = Philiprehberger::CliKit::Parser.new
      parser.flag(:verbose)
      parser.parse(%w[--verbose])

      expect(parser.help_requested?).to be false
    end

    it 'prints help and returns parser via .parse with StringIO output' do
      output = StringIO.new
      result = described_class.parse(%w[--help], output: output) do
        flag :verbose, short: :v, desc: 'Enable verbose output'
        option :output, short: :o, desc: 'Output file'
      end

      expect(output.string).to include('--verbose')
      expect(output.string).to include('Enable verbose output')
      expect(result.help_requested?).to be true
    end

    it 'returns help_text without printing' do
      parser = Philiprehberger::CliKit::Parser.new
      parser.flag(:verbose, short: :v, desc: 'Enable verbose output')
      parser.option(:env, short: :e, desc: 'Environment name')

      text = parser.help_text
      expect(text).to be_a(String)
      expect(text).to include('Options:')
      expect(text).to include('-v, --verbose')
      expect(text).to include('-e, --env VALUE')
    end

    it 'generates help with flags that have no desc' do
      parser = Philiprehberger::CliKit::Parser.new
      parser.flag(:verbose, short: :v)

      help = parser.help_text
      expect(help).to include('-v, --verbose')
    end
  end

  describe '.select' do
    it 'displays numbered menu and returns selected value' do
      input = StringIO.new("2\n")
      output = StringIO.new

      result = described_class.select('Choose env:', %w[dev staging prod], input: input, output: output)

      expect(output.string).to include('Choose env:')
      expect(output.string).to include('1) dev')
      expect(output.string).to include('2) staging')
      expect(output.string).to include('3) prod')
      expect(result).to eq('staging')
    end

    it 'returns first choice for invalid input without default' do
      input = StringIO.new("abc\n")
      output = StringIO.new

      result = described_class.select('Choose:', %w[a b c], input: input, output: output)
      expect(result).to eq('a')
    end

    it 'returns default when input is empty' do
      input = StringIO.new("\n")
      output = StringIO.new

      result = described_class.select('Choose:', %w[dev staging prod], default: 'staging', input: input, output: output)
      expect(result).to eq('staging')
    end

    it 'marks default choice with asterisk' do
      input = StringIO.new("1\n")
      output = StringIO.new

      described_class.select('Choose:', %w[dev staging prod], default: 'staging', input: input, output: output)
      expect(output.string).to include('* 2) staging')
      expect(output.string).to include('  1) dev')
    end

    it 'shows default index in prompt' do
      input = StringIO.new("\n")
      output = StringIO.new

      described_class.select('Choose:', %w[dev staging prod], default: 'staging', input: input, output: output)
      expect(output.string).to include('Choose [2]:')
    end

    it 'returns selected value overriding default' do
      input = StringIO.new("3\n")
      output = StringIO.new

      result = described_class.select('Choose:', %w[dev staging prod], default: 'staging', input: input, output: output)
      expect(result).to eq('prod')
    end

    it 'raises ArgumentError for empty choices' do
      input = StringIO.new("1\n")
      output = StringIO.new

      expect do
        described_class.select('Choose:', [], input: input, output: output)
      end.to raise_error(ArgumentError, 'choices must not be empty')
    end

    it 'handles single choice' do
      input = StringIO.new("1\n")
      output = StringIO.new

      result = described_class.select('Choose:', %w[only], input: input, output: output)
      expect(result).to eq('only')
    end

    it 'returns default for out-of-range input when default set' do
      input = StringIO.new("99\n")
      output = StringIO.new

      result = described_class.select('Choose:', %w[a b c], default: 'b', input: input, output: output)
      expect(result).to eq('b')
    end

    it 'returns first choice for out-of-range input without default' do
      input = StringIO.new("99\n")
      output = StringIO.new

      result = described_class.select('Choose:', %w[a b c], input: input, output: output)
      expect(result).to eq('a')
    end

    it 'handles EOF input with default' do
      input = StringIO.new('')
      output = StringIO.new

      result = described_class.select('Choose:', %w[a b c], default: 'c', input: input, output: output)
      expect(result).to eq('c')
    end
  end

  describe '.prompt' do
    it 'prints message and reads input' do
      input = StringIO.new("hello\n")
      output = StringIO.new

      result = described_class.prompt('Name:', input: input, output: output)

      expect(output.string).to eq('Name: ')
      expect(result).to eq('hello')
    end

    it 'strips whitespace from input' do
      input = StringIO.new("  spaced  \n")
      output = StringIO.new

      result = described_class.prompt('Value:', input: input, output: output)
      expect(result).to eq('spaced')
    end

    it 'returns empty string on EOF' do
      input = StringIO.new('')
      output = StringIO.new

      result = described_class.prompt('Value:', input: input, output: output)
      expect(result).to eq('')
    end

    it 'handles multiline input returning first line' do
      input = StringIO.new("first\nsecond\n")
      output = StringIO.new

      result = described_class.prompt('Input:', input: input, output: output)
      expect(result).to eq('first')
    end
  end

  describe '.confirm' do
    it 'returns true for y' do
      input = StringIO.new("y\n")
      output = StringIO.new

      expect(described_class.confirm('Sure?', input: input, output: output)).to be true
    end

    it 'returns true for yes' do
      input = StringIO.new("yes\n")
      output = StringIO.new

      expect(described_class.confirm('Sure?', input: input, output: output)).to be true
    end

    it 'returns true for YES (case insensitive)' do
      input = StringIO.new("YES\n")
      output = StringIO.new

      expect(described_class.confirm('Sure?', input: input, output: output)).to be true
    end

    it 'returns true for Y (uppercase)' do
      input = StringIO.new("Y\n")
      output = StringIO.new

      expect(described_class.confirm('Sure?', input: input, output: output)).to be true
    end

    it 'returns false for n' do
      input = StringIO.new("n\n")
      output = StringIO.new

      expect(described_class.confirm('Sure?', input: input, output: output)).to be false
    end

    it 'returns false for arbitrary input' do
      input = StringIO.new("maybe\n")
      output = StringIO.new

      expect(described_class.confirm('Sure?', input: input, output: output)).to be false
    end

    it 'includes [y/n] in prompt' do
      input = StringIO.new("y\n")
      output = StringIO.new

      described_class.confirm('Continue?', input: input, output: output)
      expect(output.string).to eq('Continue? [y/n] ')
    end

    it 'returns false on EOF' do
      input = StringIO.new('')
      output = StringIO.new

      expect(described_class.confirm('Sure?', input: input, output: output)).to be false
    end
  end

  describe '.spinner' do
    it 'returns the block result' do
      output = StringIO.new
      result = described_class.spinner('Working...', output: output) { 42 }
      expect(result).to eq(42)
    end

    it 'executes the block' do
      output = StringIO.new
      executed = false
      described_class.spinner('Working...', output: output) { executed = true }
      expect(executed).to be true
    end

    it 'returns nil when block returns nil' do
      output = StringIO.new
      result = described_class.spinner('Working...', output: output) { nil }
      expect(result).to be_nil
    end
  end

  describe 'multi-value options' do
    it 'collects repeated long options into an array' do
      result = described_class.parse(%w[--tag ruby --tag cli --tag kit]) do
        option :tag, multi: true
      end

      expect(result.options[:tag]).to eq(%w[ruby cli kit])
    end

    it 'collects repeated short options into an array' do
      result = described_class.parse(%w[-t a -t b]) do
        option :tag, short: :t, multi: true
      end

      expect(result.options[:tag]).to eq(%w[a b])
    end

    it 'defaults multi options to an empty array when not provided' do
      result = described_class.parse([]) do
        option :tag, multi: true
      end

      expect(result.options[:tag]).to eq([])
    end

    it 'mixes single-value and multi-value options' do
      result = described_class.parse(%w[--name foo --tag a --tag b]) do
        option :name
        option :tag, multi: true
      end

      expect(result.options[:name]).to eq('foo')
      expect(result.options[:tag]).to eq(%w[a b])
    end

    it 'shows (repeatable) hint in help text for multi options' do
      parser = Philiprehberger::CliKit::Parser.new
      parser.option(:tag, multi: true, desc: 'Add a tag')

      expect(parser.help_text).to include('--tag VALUE (repeatable)')
    end
  end

  describe '.password' do
    it 'prints the message and reads input without noecho on StringIO' do
      input = StringIO.new("secret\n")
      output = StringIO.new

      result = described_class.password('Password:', input: input, output: output)

      expect(result).to eq('secret')
      expect(output.string).to start_with('Password: ')
    end

    it 'appends a newline to the output after reading' do
      input = StringIO.new("pw\n")
      output = StringIO.new

      described_class.password('Pwd:', input: input, output: output)

      expect(output.string).to end_with("\n")
    end

    it 'returns empty string on EOF' do
      input = StringIO.new('')
      output = StringIO.new

      expect(described_class.password('Pwd:', input: input, output: output)).to eq('')
    end

    it 'uses noecho when the input responds to it' do
      input = StringIO.new("hidden\n")
      output = StringIO.new

      # Stub noecho on the StringIO instance
      def input.noecho
        yield self
      end

      result = described_class.password('Pwd:', input: input, output: output)
      expect(result).to eq('hidden')
    end

    it 'falls back to plain gets when noecho raises IOError' do
      input = StringIO.new("fallback\n")
      output = StringIO.new

      def input.noecho(*)
        raise IOError, 'not a tty'
      end

      result = described_class.password('Pwd:', input: input, output: output)
      expect(result).to eq('fallback')
    end
  end

  describe '.ask' do
    it 'returns the first non-empty answer when no block given' do
      input = StringIO.new("alice\n")
      output = StringIO.new

      result = described_class.ask('Name:', input: input, output: output)
      expect(result).to eq('alice')
    end

    it 'reprompts until validation passes' do
      input = StringIO.new("\nbob\n")
      output = StringIO.new

      result = described_class.ask('Name:', input: input, output: output)

      expect(result).to eq('bob')
      expect(output.string).to include('Invalid input')
    end

    it 'accepts answers passing the custom validator' do
      input = StringIO.new("abc\n42\n")
      output = StringIO.new

      result = described_class.ask('Port:', error: 'Not a number', input: input, output: output) do |ans|
        ans.match?(/\A\d+\z/)
      end

      expect(result).to eq('42')
      expect(output.string).to include('Not a number')
    end

    it 'returns empty string on EOF' do
      input = StringIO.new('')
      output = StringIO.new

      expect(described_class.ask('Name:', input: input, output: output)).to eq('')
    end
  end

  describe '.multi_select' do
    it 'returns selections from a comma-separated answer' do
      input = StringIO.new("1,3\n")
      output = StringIO.new

      result = described_class.multi_select('Pick:', %w[a b c d], input: input, output: output)

      expect(result).to eq(%w[a c])
      expect(output.string).to include('1) a')
      expect(output.string).to include('Choose (comma-separated):')
    end

    it 'accepts space-separated answers' do
      input = StringIO.new("2 4\n")
      output = StringIO.new

      result = described_class.multi_select('Pick:', %w[a b c d], input: input, output: output)
      expect(result).to eq(%w[b d])
    end

    it 'ignores out-of-range and non-numeric tokens' do
      input = StringIO.new("1, foo, 99, 2\n")
      output = StringIO.new

      result = described_class.multi_select('Pick:', %w[a b c], input: input, output: output)
      expect(result).to eq(%w[a b])
    end

    it 'collapses duplicate selections' do
      input = StringIO.new("1,1,2\n")
      output = StringIO.new

      result = described_class.multi_select('Pick:', %w[a b c], input: input, output: output)
      expect(result).to eq(%w[a b])
    end

    it 'returns defaults when the answer is empty' do
      input = StringIO.new("\n")
      output = StringIO.new

      result = described_class.multi_select('Pick:', %w[a b c], defaults: %w[b], input: input, output: output)
      expect(result).to eq(%w[b])
    end

    it 'marks default choices with an asterisk' do
      input = StringIO.new("\n")
      output = StringIO.new

      described_class.multi_select('Pick:', %w[a b c], defaults: %w[a c], input: input, output: output)

      expect(output.string).to include('* 1) a')
      expect(output.string).to include('  2) b')
      expect(output.string).to include('* 3) c')
    end

    it 'returns an empty array when no defaults and empty answer' do
      input = StringIO.new("\n")
      output = StringIO.new

      result = described_class.multi_select('Pick:', %w[a b], input: input, output: output)
      expect(result).to eq([])
    end

    it 'raises ArgumentError for empty choices' do
      input = StringIO.new("1\n")
      output = StringIO.new

      expect do
        described_class.multi_select('Pick:', [], input: input, output: output)
      end.to raise_error(ArgumentError, 'choices must not be empty')
    end

    it 'returns results in choice order regardless of input order' do
      input = StringIO.new("3,1\n")
      output = StringIO.new

      result = described_class.multi_select('Pick:', %w[a b c], input: input, output: output)
      expect(result).to eq(%w[a c])
    end
  end

  describe 'required options' do
    it 'raises CliKit::Error with the option name when a required option is missing' do
      expect do
        described_class.parse([]) do
          option :env, required: true
        end
      end.to raise_error(Philiprehberger::CliKit::Error, /--env/)
    end

    it 'lists all missing required options in a single error message' do
      expect do
        described_class.parse([]) do
          option :env, required: true
          option :name, required: true
        end
      end.to raise_error(Philiprehberger::CliKit::Error) do |error|
        expect(error.message).to include('--env')
        expect(error.message).to include('--name')
      end
    end

    it 'parses normally when a required option is supplied' do
      result = described_class.parse(%w[--env staging]) do
        option :env, required: true
      end

      expect(result.options[:env]).to eq('staging')
    end

    it 'does not raise for options that are not required' do
      expect do
        described_class.parse([]) do
          option :env
        end
      end.not_to raise_error
    end

    it 'appends (required) to the help text for a required option' do
      parser = Philiprehberger::CliKit::Parser.new
      parser.option(:env, short: :e, desc: 'Target environment', required: true)

      expect(parser.help_text).to include('Target environment (required)')
    end
  end
end
