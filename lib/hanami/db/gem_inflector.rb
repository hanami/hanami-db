# frozen_string_literal: true

module Hanami
  module DB
    # @api private
    class GemInflector < Zeitwerk::GemInflector
      def camelize(basename, _abspath)
        return "DB" if basename == "db"
        return "SQLite" if basename == "sqlite"
        return "DatabaseURL" if basename == "database_url"

        super
      end
    end
  end
end
