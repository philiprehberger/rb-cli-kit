# frozen_string_literal: true

module Philiprehberger
  module CliKit
    # Interactive prompt utilities for CLI applications.
    module Prompt
      # Display a prompt and read user input.
      #
      # @param message [String] the prompt message
      # @param input [IO] input stream (default: $stdin)
      # @param output [IO] output stream (default: $stdout)
      # @return [String] the user's input, stripped of whitespace
      def self.prompt(message, input: $stdin, output: $stdout)
        output.print "#{message} "
        output.flush
        input.gets&.strip || ''
      end

      # Display a yes/no confirmation prompt.
      #
      # @param message [String] the confirmation message
      # @param input [IO] input stream (default: $stdin)
      # @param output [IO] output stream (default: $stdout)
      # @return [Boolean] true if user answered yes
      def self.confirm(message, input: $stdin, output: $stdout)
        output.print "#{message} [y/n] "
        output.flush
        answer = input.gets&.strip&.downcase || ''
        %w[y yes].include?(answer)
      end
    end
  end
end
