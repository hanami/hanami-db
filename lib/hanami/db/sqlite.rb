# frozen_string_literal: true

module Hanami
  module DB
    module SQLite
      MEMORY_URL = RUBY_ENGINE == "jruby" ? "jdbc:sqlite::memory:" : "sqlite::memory:"
    end
  end
end
