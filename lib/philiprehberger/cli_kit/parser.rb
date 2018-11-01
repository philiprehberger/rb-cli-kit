# frozen_string_literal: true

module Philiprehberger
  module CliKit
    # DSL-based argument parser for CLI applications.
    class Parser
      attr_reader :flags, :options, :arguments

      def initialize
        @flag_definitions = {}
        @option_definitions = {}
        @command_definitions = {}
        @flags = {}
        @options = {}
        @arguments = []
        @command_name = nil
        @program_name = nil
      end

      # Define a boolean flag.
      #
      # @param name [Symbol] the flag name
      # @param short [Symbol, nil] short alias (single character)
      # @param desc [String, nil] description for help text
      # @return [void]
      def flag(name, short: nil, desc: nil)
        @flag_definitions[name] = { short: short, desc: desc }
        @flags[name] = false
      end

      # Define a value option.
      #
      # @param name [Symbol] the option name
      # @param short [Symbol, nil] short alias (single character)
      # @param default [Object, nil] default value
      # @param desc [String, nil] description for help text
      # @return [void]
      def option(name, short: nil, default: nil, desc: nil)
        @option_definitions[name] = { short: short, default: default, desc: desc }
        @options[name] = default
      end

      # Define a subcommand or return the matched command name.
      #
      # When called with a name and block, defines a subcommand.
      # When called with no arguments, returns the matched command name.
      #
      # @param name [Symbol, nil] the command name (nil to query)
      # @yield [Parser] the command parser for defining command-specific flags and options
      # @return [Symbol, nil, void]
      def command(name = nil, &block)
        if name.nil?
          @command_name
        else
          cmd_parser = Parser.new
          cmd_parser.instance_eval(&block) if block
          @command_definitions[name] = cmd_parser
        end
      end

      # Return the matched command name, or nil if no command matched.
      #
      # @return [Symbol, nil]
      def command_name
        @command_name
      end

      # Return the formatted help text without printing.
      #
      # @return [String]
      def help_text
        lines = []
        lines << "Usage: #{@program_name || 'command'} [options]"
        lines << ''

        unless @flag_definitions.empty? && @option_definitions.empty?
          lines << 'Options:'
          @flag_definitions.each do |name, defn|
            lines << format_flag_help(name, defn)
          end
          @option_definitions.each do |name, defn|
            lines << format_option_help(name, defn)
          end
        end

        unless @command_definitions.empty?
          lines << '' unless @flag_definitions.empty? && @option_definitions.empty?
          lines << 'Commands:'
          @command_definitions.each_key do |name|
            lines << "  #{name}"
          end
        end

        lines.join("\n")
      end

      # Parse the given argument array.
      #
      # @param args [Array<String>] command-line arguments
      # @return [self]
      def parse(args)
        args = args.dup

        # Check for --help / -h before anything else
        if args.include?('--help') || args.include?('-h')
          @help_requested = true
          return self
        end

        # Try to match a subcommand
        if @command_definitions.any? && args.any?
          potential_cmd = args.first.to_sym
          if @command_definitions.key?(potential_cmd)
            @command_name = potential_cmd
            cmd_parser = @command_definitions[potential_cmd]
            args.shift
            cmd_parser.parse(args)
            @flags = cmd_parser.flags
            @options = cmd_parser.options
            @arguments = cmd_parser.arguments
            return self
          end
        end

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

      # Check if help was requested.
      #
      # @return [Boolean]
      def help_requested?
        @help_requested || false
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

      def format_flag_help(name, defn)
        long = "--#{name.to_s.tr('_', '-')}"
        if defn[:short]
          short = "-#{defn[:short]}"
          label = "  #{short}, #{long}"
        else
          label = "      #{long}"
        end
        if defn[:desc]
          "#{label.ljust(24)}#{defn[:desc]}"
        else
          label
        end
      end

      def format_option_help(name, defn)
        long = "--#{name.to_s.tr('_', '-')} VALUE"
        if defn[:short]
          short = "-#{defn[:short]}"
          label = "  #{short}, #{long}"
        else
          label = "      #{long}"
        end
        if defn[:desc]
          "#{label.ljust(24)}#{defn[:desc]}"
        else
          label
        end
      end
    end
  end
end
