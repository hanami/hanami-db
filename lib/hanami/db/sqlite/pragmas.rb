# frozen_string_literal: true

module Hanami
  module DB
    module SQLite
      # SQLite pragmas applied to every new connection, with sensible defaults.
      class Pragmas
        # `foreign_keys` is omitted: Sequel's adapter already enables it.
        DEFAULTS = {
          journal_mode: :wal,
          synchronous: :normal,
          mmap_size: 128 * 1024 * 1024,
          journal_size_limit: 64 * 1024 * 1024,
          cache_size: 2_000
        }.freeze

        NAMES_MUTEX = Mutex.new
        private_constant :NAMES_MUTEX

        # The authoritative set of pragma names SQLite recognises, queried
        # via `PRAGMA pragma_list` (here through its table-valued form,
        # `pragma_pragma_list`) against a transient in-memory connection
        # on first access. Requires SQLite 3.30+, where `pragma_list` is
        # compiled in by default. Reflects whatever SQLite the runtime has
        # linked, so newer pragmas appear automatically without a gem upgrade.
        # Memoized at the class level; the in-memory handle is opened at
        # most once per class load. The mutex guards concurrent first
        # access (e.g. parallel connection warmup at boot). The block form
        # of `Sequel.connect` is required: it disconnects *and* removes the
        # handle from `Sequel::DATABASES`, so we leave no stray database
        # registered for tools that inspect that list (DatabaseCleaner
        # refuses to run when it sees more than one).
        def self.names
          @names || NAMES_MUTEX.synchronize do
            @names ||= Sequel.connect(MEMORY_URL) do |db|
              db.fetch("SELECT name FROM pragma_pragma_list").map { |row| row[:name].to_sym }.to_set.freeze
            end
          end
        end

        def initialize(overrides: {}, clear_defaults: false)
          base = clear_defaults ? {} : DEFAULTS
          @resolved = base.merge(overrides.transform_keys(&:to_sym)).freeze
          validate_names!
        end

        def to_h
          @resolved
        end

        # Runs after the adapter's own `connection_pragmas`, so an override
        # naming a pragma Sequel also sets will win.
        def connect_sqls
          @resolved.map { |name, value| "PRAGMA #{name} = #{value}" }
        end

        private

        def validate_names!
          unknown = @resolved.keys.reject { self.class.names.include?(_1) }
          raise UnknownPragmaError.new(unknown) unless unknown.empty?
        end
      end
    end
  end
end
