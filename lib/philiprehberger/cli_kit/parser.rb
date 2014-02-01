# frozen_string_literal: true

module Philiprehberger
  module CliKit
    # DSL-based argument parser for CLI applications.
    class Parser
      attr_reader :flags, :options, :arguments

      def initialize
        @flag_definitions = {}
        @option_definitions = {}
        @flags = {}
        @options = {}
        @arguments = []
      end

      # Define a boolean flag.
      #
      # @param name [Symbol] the flag name
      # @param short [Symbol, nil] short alias (single character)
      # @return [void]
      def flag(name, short: nil)
        @flag_definitions[name] = { short: short }
        @flags[name] = false
      end

      # Define a value option.
      #
      # @param name [Symbol] the option name
      # @param short [Symbol, nil] short alias (single character)
      # @param default [Object, nil] default value
      # @return [void]
      def option(name, short: nil, default: nil)
        @option_definitions[name] = { short: short, default: default }
        @options[name] = default
      end

      # Parse the given argument array.
      #
      # @param args [Array<String>] command-line arguments
      # @return [self]
      def parse(args)
        args = args.dup
        while args.any?
          arg = args.shift
          if arg.start_with?('--')
            parse_long(arg, args)
          elsif arg.start_with?('-') && arg.length > 1
            parse_short(arg, args)
          else
            @arguments << arg
          end
        end
        self
      end

      private

      def parse_long(arg, args)
        name = arg.sub(/\A--/, '').tr('-', '_').to_sym
        if @flag_definitions.key?(name)
          @flags[name] = true
        elsif @option_definitions.key?(name)
          @options[name] = args.shift
        end
      end

      def parse_short(arg, args)
        char = arg.sub(/\A-/, '').to_sym

        @flag_definitions.each do |name, defn|
          if defn[:short] == char
            @flags[name] = true
            return
          end
        end

        @option_definitions.each do |name, defn|
          if defn[:short] == char
            @options[name] = args.shift
            return
          end
        end
      end
    end
  end
end
