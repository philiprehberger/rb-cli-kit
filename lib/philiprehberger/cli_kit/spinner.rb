# frozen_string_literal: true

module Philiprehberger
  module CliKit
    # Animated spinner for long-running CLI operations.
    module Spinner
      FRAMES = %w[| / - \\].freeze

      # Display a spinner while executing a block.
      #
      # @param message [String] the message to display alongside the spinner
      # @param output [IO] output stream (default: $stderr)
      # @yield the block to execute
      # @return [Object] the return value of the block
      def self.spinner(message, output: $stderr, &block)
        done = false
        result = nil

        thread = Thread.new do
          frame = 0
          until done
            output.print "\r#{FRAMES[frame % FRAMES.length]} #{message}"
            output.flush
            frame += 1
            sleep 0.1
          end
          output.print "\r\e[K"
          output.flush
        end

        begin
          result = block.call
        ensure
          done = true
          thread.join
        end

        result
      end
    end
  end
end
