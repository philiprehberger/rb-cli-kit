# frozen_string_literal: true

require_relative 'cli_kit/version'
require_relative 'cli_kit/parser'
require_relative 'cli_kit/prompt'
require_relative 'cli_kit/spinner'

module Philiprehberger
  module CliKit
    class Error < StandardError; end

    # Parse command-line arguments using a DSL block.
    #
    # @param args [Array<String>] command-line arguments
    # @yield [Parser] the parser for defining flags and options
    # @return [Parser] the parsed result with flags, options, and arguments
    def self.parse(args, &)
      parser = Parser.new
      parser.instance_eval(&)
      parser.parse(args)
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

    # Display a spinner while executing a block.
    #
    # @param message [String] the spinner message
    # @param output [IO] output stream
    # @yield the block to execute
    # @return [Object] the return value of the block
    def self.spinner(message, output: $stderr, &block)
      Spinner.spinner(message, output: output, &block)
    end
  end
end
