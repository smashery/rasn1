# frozen_string_literal: true

module RASN1
  # @private
  class Tracer
    attr_reader :io

    def initialize(io)
      @io = io
    end

    def trace(msg)
      @io.puts(msg)
    end
  end

  def self.trace(io=$stdout)
    @tracer = Tracer.new(io)
    [Types::Any, Types::Choice, Types::Base].each(&:start_tracing)

    begin
      yield @tracer
    ensure
      [Types::Base, Types::Choice, Types::Any].each(&:stop_tracing)
      @tracer.io.flush
      @tracer = nil
    end
  end

  # @private
  def self.trace_message
    yield @tracer
  end

  module Types
    class Base
      class << self
        def start_tracing
          alias_method :do_parse_without_tracing, :do_parse
          alias_method :do_parse, :do_parse_with_tracing
        end

        def stop_tracing
          alias_method :do_parse, :do_parse_without_tracing # rubocop:disable Lint/DuplicateMethods
        end
      end

      def do_parse_with_tracing(der, ber)
        ret = do_parse_without_tracing(der, ber)
        RASN1.trace_message do |tracer|
          tracer.trace(self.trace)
        end
        ret
      end
    end

    class Choice
      class << self
        def start_tracing
          alias_method :parse_without_tracing, :parse!
          alias_method :parse!, :parse_with_tracing
        end

        def stop_tracing
          alias_method :parse!, :parse_without_tracing # rubocop:disable Lint/DuplicateMethods
        end
      end

      def parse_with_tracing(der, ber: false)
        RASN1.trace_message do |tracer|
          tracer.trace(self.trace)
        end
        parse_without_tracing(der, ber: ber)
      end
    end
  end
end
