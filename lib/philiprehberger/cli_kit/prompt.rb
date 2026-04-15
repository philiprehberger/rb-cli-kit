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

      # Display a prompt and read input without echoing characters to the terminal.
      #
      # When the input stream responds to +noecho+ (a real TTY), echo is disabled
      # for the duration of the read. When it does not (e.g. a +StringIO+ during
      # tests), input is read normally. A trailing newline is printed to the
      # output after the read so the next prompt starts on its own line.
      #
      # @param message [String] the prompt message
      # @param input [IO] input stream (default: $stdin)
      # @param output [IO] output stream (default: $stdout)
      # @return [String] the user's input, stripped of whitespace
      def self.password(message, input: $stdin, output: $stdout)
        output.print "#{message} "
        output.flush

        raw = if input.respond_to?(:noecho)
                begin
                  input.noecho(&:gets)
                rescue IOError, Errno::ENOTTY
                  input.gets
                end
              else
                input.gets
              end

        output.print "\n"
        output.flush
        raw&.strip || ''
      end

      # Display a prompt and read input, repeating until it passes validation.
      #
      # The block is called with the stripped input; when it returns a truthy
      # value the input is accepted and returned. When it returns a falsy value
      # an optional +error+ message is printed and the user is prompted again.
      # When no block is given, any non-empty input is accepted.
      #
      # @param message [String] the prompt message
      # @param error [String] the message shown on invalid input
      # @param input [IO] input stream (default: $stdin)
      # @param output [IO] output stream (default: $stdout)
      # @yieldparam answer [String] the stripped user input
      # @yieldreturn [Boolean] whether the answer is acceptable
      # @return [String] the accepted user input
      def self.ask(message, error: 'Invalid input, please try again.', input: $stdin, output: $stdout, &block)
        validator = block || ->(answer) { !answer.empty? }

        loop do
          output.print "#{message} "
          output.flush
          raw = input.gets
          return '' if raw.nil?

          answer = raw.strip
          return answer if validator.call(answer)

          output.puts error
        end
      end
    end
  end
end
