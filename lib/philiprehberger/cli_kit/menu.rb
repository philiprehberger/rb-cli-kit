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

      # Present a numbered menu and allow multiple selections.
      #
      # The user enters a comma- or space-separated list of numbers (e.g.
      # "1,3" or "1 3"). Unknown or out-of-range entries are ignored, and
      # duplicates are collapsed. An empty answer returns +defaults+ or an
      # empty array if no defaults are given.
      #
      # @param message [String] the prompt message
      # @param choices [Array<String>] the list of choices
      # @param defaults [Array<String>] choices pre-selected by default
      # @param input [IO] input stream (default: $stdin)
      # @param output [IO] output stream (default: $stdout)
      # @return [Array<String>] the selected values in choice order
      # @raise [ArgumentError] if choices is empty
      def self.multi_select(message, choices, defaults: [], input: $stdin, output: $stdout)
        raise ArgumentError, 'choices must not be empty' if choices.empty?

        default_indexes = defaults.map { |d| choices.index(d) }.compact

        output.puts message
        choices.each_with_index do |choice, idx|
          marker = default_indexes.include?(idx) ? '*' : ' '
          output.puts "  #{marker} #{idx + 1}) #{choice}"
        end

        output.print 'Choose (comma-separated): '
        output.flush

        answer = input.gets&.strip || ''
        return defaults.dup if answer.empty?

        picks = answer.split(/[,\s]+/).filter_map do |token|
          idx = Integer(token, 10) - 1
          idx if idx >= 0 && idx < choices.length
        rescue ArgumentError
          nil
        end

        picks.uniq.sort.map { |i| choices[i] }
      end
    end
  end
end
