# frozen_string_literal: true

module Hanami
  module DB
    module SQLite
      class UnknownPragmaError < StandardError
        attr_reader :unknown

        def initialize(unknown)
          @unknown = unknown.dup.freeze
          super(build_message(@unknown))
        end

        private

        def build_message(unknown)
          "Unknown SQLite pragma(s): #{unknown.join(", ")}. " \
            "If you have confirmed this pragma is supported by your SQLite build, " \
            "construct Hanami::DB::SQLite::Pragmas with `validate: false` to bypass " \
            "name validation."
        end
      end
    end
  end
end
