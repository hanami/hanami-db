# frozen_string_literal: true

module Hanami
  module DB
    # Base error class for all Hanami::DB errors.
    #
    # @since 3.1.0
    # @api public
    class Error < StandardError
    end

    # Raised when a database URL cannot be parsed.
    #
    # Takes only the URL's scheme rather than the URL itself, since the URL may contain credentials.
    #
    # @since 3.1.0
    # @api public
    class InvalidURLError < Error
      def initialize(scheme)
        super(
          "`#{scheme || "(none)"}' database URL could not be parsed. " \
          "Check it for characters that need escaping, such as in the password"
        )
      end
    end

    # Raised when SQLite pragma overrides name pragmas that the linked SQLite does not recognize.
    #
    # @since 3.1.0
    # @api public
    class UnknownPragmaError < Error
      # @return [Array<Symbol>] the unknown pragma names
      attr_reader :unknown

      def initialize(unknown)
        @unknown = unknown.dup.freeze
        super("Unknown SQLite pragma(s): #{unknown.join(", ")}.")
      end
    end
  end
end
