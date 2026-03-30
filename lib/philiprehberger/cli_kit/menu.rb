# frozen_string_literal: true

module Philiprehberger
  module CliKit
    # Numbered menu selection for CLI applications.
    module Menu
      # Present a numbered menu and return the selected value.
      #
      # @param message [String] the prompt message
      # @param choices [Array<String>] the list of choices
      # @param default [String, nil] pre-selected default choice
      # @param input [IO] input stream (default: $stdin)
      # @param output [IO] output stream (default: $stdout)
      # @return [String] the selected value
      # @raise [ArgumentError] if choices is empty
      def self.select(message, choices, default: nil, input: $stdin, output: $stdout)
        raise ArgumentError, 'choices must not be empty' if choices.empty?

        default_index = default ? choices.index(default) : nil

        output.puts message
        choices.each_with_index do |choice, idx|
          marker = default_index == idx ? '*' : ' '
          output.puts "  #{marker} #{idx + 1}) #{choice}"
        end

        prompt_text = default ? "Choose [#{default_index + 1}]: " : 'Choose: '
        output.print prompt_text
        output.flush

        answer = input.gets&.strip || ''

        if answer.empty? && default
          return default
        end

        index = answer.to_i - 1
        if index >= 0 && index < choices.length
          choices[index]
        elsif default
          default
        else
          choices.first
        end
      end
    end
  end
end
