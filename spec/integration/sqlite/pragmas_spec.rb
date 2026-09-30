# frozen_string_literal: true

require "sequel"
require "tempfile"

RSpec.describe Hanami::DB::SQLite::Pragmas do
  describe "#connect_sqls" do
    subject(:pragmas) { described_class.new(overrides: overrides) }

    let(:overrides) { {synchronous: :full} }
    let(:tempfile) { Tempfile.new(["hanami-db-pragmas", ".sqlite"]) }
    let(:db) do
      Sequel.connect(sqlite_file_database_url(tempfile.path), connect_sqls: pragmas.connect_sqls)
    end

    after do
      db.disconnect
      tempfile.close
      tempfile.unlink
    end

    def pragma(name)
      db.fetch("PRAGMA #{name}").first&.fetch(name)
    end

    context "when passed to Sequel.connect" do
      it "sets journal_mode to wal" do
        expect(pragma(:journal_mode)).to eq("wal")
      end

      it "applies user overrides over defaults" do
        expect(pragma(:synchronous).to_i).to eq(2) # full = 2
      end

      it "leaves unrelated defaults applied" do
        expect(pragma(:cache_size).to_i).to eq(2_000)
      end

      it "applies the pragmas to every new pool connection, not just the first" do
        # Force a second physical connection to be opened from the pool.
        db.pool.hold { |_conn| }
        db.pool.hold { |_conn| }

        expect(pragma(:journal_mode)).to eq("wal")
      end

      # The full set of settings a connection ends up with, whether they
      # come from Pragmas::DEFAULTS or from Sequel's SQLite adapter.
      # Sequel's are pinned too, so a Sequel upgrade that changes one
      # fails here.
      context "with no overrides" do
        let(:overrides) { {} }

        it "sets journal_mode to wal" do
          expect(pragma(:journal_mode)).to eq("wal")
        end

        it "sets synchronous to normal" do
          expect(pragma(:synchronous).to_i).to eq(1) # normal = 1
        end

        it "sets mmap_size to 128MiB" do
          expect(pragma(:mmap_size).to_i).to eq(128 * 1024 * 1024)
        end

        it "sets journal_size_limit to 64MiB" do
          expect(pragma(:journal_size_limit).to_i).to eq(64 * 1024 * 1024)
        end

        it "sets cache_size to 2000 pages" do
          expect(pragma(:cache_size).to_i).to eq(2_000)
        end

        it "relies on Sequel to enable foreign keys" do
          expect(pragma(:foreign_keys).to_i).to eq(1)
        end

        # case_sensitive_like is write-only, so check its effect instead.
        it "relies on Sequel to make LIKE case-sensitive" do
          expect(db.get(Sequel.lit("'a' LIKE 'A'")).to_i).to eq(0)
        end

        # Sequel's MRI adapter sets 5000ms; its JDBC adapter sets nothing,
        # leaving sqlite-jdbc's own default.
        it "relies on the adapter for a busy timeout" do
          timeout = db.fetch("PRAGMA busy_timeout").first.fetch(:timeout)

          expect(timeout.to_i).to eq(RUBY_ENGINE == "jruby" ? 3_000 : 5_000)
        end

        it "relies on Sequel to store booleans as integers and read them back as booleans" do
          db.create_table(:flags) do
            primary_key :id
            TrueClass :flag
          end
          db[:flags].insert(flag: true)
          db[:flags].insert(flag: false)

          expect(db[:flags].order(:id).select_map(:flag)).to eq([true, false])
          expect(db.fetch("SELECT typeof(flag) AS type FROM flags").map(:type)).to all(eq("integer"))
        end
      end

      context "with an override naming a pragma Sequel also sets" do
        let(:overrides) { {foreign_keys: 0} }

        it "wins, because connect_sqls runs after the adapter's own pragmas" do
          expect(pragma(:foreign_keys).to_i).to eq(0)
        end
      end
    end
  end

  describe ".names" do
    before { described_class.instance_variable_set(:@names, nil) }
    after { described_class.instance_variable_set(:@names, nil) }

    it "leaves no trace of its in-memory connection in Sequel::DATABASES" do
      expect { described_class.names }.not_to change { Sequel::DATABASES.size }
    end
  end
end
