# frozen_string_literal: true

module Philiprehberger
  module CliKit
    # ANSI color and style helpers. Output is auto-disabled when stdout is not a
    # TTY or the NO_COLOR environment variable is set (per https://no-color.org).
    module Colorize
      CODES = {
        red: 31, green: 32, yellow: 33, blue: 34,
        magenta: 35, cyan: 36, white: 37, gray: 90
      }.freeze

      module_function

      # @return [Boolean] true when ANSI escape codes should be emitted
      def enabled?
        return false if ENV.key?('NO_COLOR')

        $stdout.tty?
      end

      # Wraps text in an ANSI color escape, or returns it untouched when colors
      # are disabled.
      #
      # @param text [String]
      # @param name [Symbol] one of :red, :green, :yellow, :blue, :magenta, :cyan, :white, :gray
      # @return [String]
      def color(text, name)
        return text unless enabled?

        code = CODES.fetch(name) { raise ArgumentError, "unknown color: #{name.inspect}" }
        "\e[#{code}m#{text}\e[0m"
      end

      # @param text [String]
      # @return [String]
      def bold(text)
        return text unless enabled?

        "\e[1m#{text}\e[0m"
      end

      # @param text [String]
      # @return [String]
      def dim(text)
        return text unless enabled?

        "\e[2m#{text}\e[0m"
      end
    end
  end
end
