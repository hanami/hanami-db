# frozen_string_literal: true

require "sequel"
require "tempfile"

RSpec.describe "SQLite Pragmas integration" do
  subject(:pragmas) { Hanami::DB::SQLite::Pragmas.new(overrides: overrides) }

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

  it "sets foreign_keys" do
    expect(pragma(:foreign_keys).to_i).to eq(1)
  end

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
end
