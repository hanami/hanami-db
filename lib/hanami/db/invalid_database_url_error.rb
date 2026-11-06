# frozen_string_literal: true

module Hanami
  module DB
    # Raised when a database URL cannot be parsed.
    #
    # Takes only the URL's scheme rather than the URL itself, since the URL may contain
    # credentials.
    #
    # @since 3.1.0
    # @api public
    class InvalidDatabaseURLError < StandardError
      def initialize(scheme)
        super(
          "`#{scheme || "(none)"}' database URL could not be parsed. " \
          "Check it for characters that need escaping, such as in the password"
        )
      end
    end
  end
end
