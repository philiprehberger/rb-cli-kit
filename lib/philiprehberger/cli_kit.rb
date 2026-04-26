# frozen_string_literal: true

require_relative 'cli_kit/version'
require_relative 'cli_kit/parser'
require_relative 'cli_kit/prompt'
require_relative 'cli_kit/spinner'
require_relative 'cli_kit/menu'
require_relative 'cli_kit/colorize'

module Philiprehberger
  module CliKit
    class Error < StandardError; end

    # Parse command-line arguments using a DSL block.
    #
    # @param args [Array<String>] command-line arguments
    # @param output [IO] output stream for help text (default: $stdout)
    # @yield [Parser] the parser for defining flags, options, and commands
    # @return [Parser] the parsed result with flags, options, and arguments
    def self.parse(args, output: $stdout, &)
      parser = Parser.new
      parser.instance_eval(&)
      parser.parse(args)

      if parser.help_requested?
        output.puts parser.help_text
        exit 0 unless output.is_a?(StringIO)
      end

      parser
    end

    # Display a prompt and read user input.
    #
    # @param message [String] the prompt message
    # @param input [IO] input stream
    # @param output [IO] output stream
    # @return [String] the user's input
    def self.prompt(message, input: $stdin, output: $stdout)
      Prompt.prompt(message, input: input, output: output)
    end

    # Display a yes/no confirmation prompt.
    #
    # @param message [String] the confirmation message
    # @param input [IO] input stream
    # @param output [IO] output stream
    # @return [Boolean] true if user answered yes
    def self.confirm(message, input: $stdin, output: $stdout)
      Prompt.confirm(message, input: input, output: output)
    end

    # Display a prompt and read input without echoing to the terminal.
    #
    # @param message [String] the prompt message
    # @param input [IO] input stream
    # @param output [IO] output stream
    # @return [String] the user's input
    def self.password(message, input: $stdin, output: $stdout)
      Prompt.password(message, input: input, output: output)
    end

    # Display a prompt, re-asking until the answer satisfies the given block.
    #
    # @param message [String] the prompt message
    # @param error [String] error message shown on invalid input
    # @param input [IO] input stream
    # @param output [IO] output stream
    # @yieldparam answer [String] the stripped user input
    # @yieldreturn [Boolean] whether the answer is acceptable
    # @return [String] the accepted user input
    def self.ask(message, error: 'Invalid input, please try again.', input: $stdin, output: $stdout, &block)
      Prompt.ask(message, error: error, input: input, output: output, &block)
    end

    # Display a spinner while executing a block.
    #
    # @param message [String] the spinner message
    # @param output [IO] output stream
    # @yield the block to execute
    # @return [Object] the return value of the block
    def self.spinner(message, output: $stderr, &block)
      Spinner.spinner(message, output: output, &block)
    end

    # Present a numbered menu and return the selected value.
    #
    # @param message [String] the prompt message
    # @param choices [Array<String>] the list of choices
    # @param default [String, nil] pre-selected default choice
    # @param input [IO] input stream
    # @param output [IO] output stream
    # @return [String] the selected value
    def self.select(message, choices, default: nil, input: $stdin, output: $stdout)
      Menu.select(message, choices, default: default, input: input, output: output)
    end

    # Present a numbered menu allowing multiple selections and return the selected values.
    #
    # @param message [String] the prompt message
    # @param choices [Array<String>] the list of choices
    # @param defaults [Array<String>] pre-selected default choices
    # @param input [IO] input stream
    # @param output [IO] output stream
    # @return [Array<String>] the selected values
    def self.multi_select(message, choices, defaults: [], input: $stdin, output: $stdout)
      Menu.multi_select(message, choices, defaults: defaults, input: input, output: output)
    end

    # Wraps text in ANSI color (auto-disabled when not a TTY or NO_COLOR is set).
    #
    # @param text [String]
    # @param name [Symbol]
    # @return [String]
    def self.color(text, name)
      Colorize.color(text, name)
    end

    # @param text [String]
    # @return [String]
    def self.bold(text)
      Colorize.bold(text)
    end

    # @param text [String]
    # @return [String]
    def self.dim(text)
      Colorize.dim(text)
    end
  end
end
