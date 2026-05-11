# frozen_string_literal: true

module Test
  module Helpers
    def sqlite_memory_database_url
      if RUBY_PLATFORM == "java"
        "jdbc:sqlite:file::memory:?cache=private"
      else
        "sqlite:file::memory:?cache=private"
      end
    end

    def sqlite_file_database_url(path)
      if RUBY_PLATFORM == "java"
        "jdbc:sqlite:#{path}"
      else
        "sqlite://#{path}"
      end
    end
  end
end

RSpec.configure do |config|
  config.include Test::Helpers
end
