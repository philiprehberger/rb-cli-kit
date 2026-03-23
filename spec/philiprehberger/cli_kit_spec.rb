# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Philiprehberger::CliKit do
  describe 'VERSION' do
    it 'has a version number' do
      expect(Philiprehberger::CliKit::VERSION).not_to be_nil
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

  describe '.confirm' do
    it 'returns false on EOF' do
      input = StringIO.new('')
      output = StringIO.new

      expect(described_class.confirm('Sure?', input: input, output: output)).to be false
    end

    it 'returns true for Y (uppercase)' do
      input = StringIO.new("Y\n")
      output = StringIO.new

      expect(described_class.confirm('Sure?', input: input, output: output)).to be true
    end
  end

  describe '.prompt' do
    it 'handles multiline input returning first line' do
      input = StringIO.new("first\nsecond\n")
      output = StringIO.new

      result = described_class.prompt('Input:', input: input, output: output)
      expect(result).to eq('first')
    end
  end
end
