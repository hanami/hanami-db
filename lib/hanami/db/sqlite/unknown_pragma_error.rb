# frozen_string_literal: true

module Hanami
  module DB
    module SQLite
      class UnknownPragmaError < StandardError
        attr_reader :unknown

        def initialize(unknown)
          @unknown = unknown.dup.freeze
          super("Unknown SQLite pragma(s): #{unknown.join(", ")}.")
        end
      end
    end
  end
end
