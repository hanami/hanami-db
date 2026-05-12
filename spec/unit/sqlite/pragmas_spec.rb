# frozen_string_literal: true

RSpec.describe Hanami::DB::SQLite::Pragmas do
  subject { described_class.new(**args) }

  let(:args) { {} }

  describe "DEFAULTS" do
    it "is frozen" do
      expect(described_class::DEFAULTS).to be_frozen
    end

    it "is the chosen set of pragmas" do
      expect(described_class::DEFAULTS).to eq(
        foreign_keys: true,
        journal_mode: :wal,
        synchronous: :normal,
        mmap_size: 128 * 1024 * 1024,
        journal_size_limit: 64 * 1024 * 1024,
        cache_size: 2_000,
      )
    end
  end

  describe "#to_h" do
    context "with no arguments" do
      it "returns the default set" do
        expect(subject.to_h).to eq(described_class::DEFAULTS)
      end
    end

    context "with overrides" do
      let(:args) { {overrides: {synchronous: "full", cache_size: 4_000}} }

      it "overrides matching defaults" do
        expect(subject.to_h.fetch(:synchronous)).to eq("full")
      end

      it "replaces overridden default values" do
        expect(subject.to_h.fetch(:cache_size)).to eq(4_000)
      end

      it "keeps unaffected defaults" do
        expect(subject.to_h.fetch(:journal_mode)).to eq(:wal)
      end
    end

    context "with clear_defaults: true" do
      let(:args) { {clear_defaults: true, overrides: {foreign_keys: 1}} }

      it "drops the entire default set" do
        expect(subject.to_h.keys).to eq([:foreign_keys])
      end
    end

    context "with clear_defaults: true and no overrides" do
      let(:args) { {clear_defaults: true} }

      it "produces an empty resolved set" do
        expect(subject.to_h).to be_empty
      end
    end

    context "with string-keyed overrides" do
      let(:args) { {overrides: {"synchronous" => "full"}} }

      it "normalizes the key to a symbol" do
        expect(subject.to_h.fetch(:synchronous)).to eq("full")
      end

      it "does not leak the string key into the resolved set" do
        expect(subject.to_h.keys).to all(be_a(Symbol))
      end
    end
  end

  describe "validation" do
    context "with an unknown override pragma name" do
      let(:args) { {overrides: {frobnicate: 1}} }

      it "raises UnknownPragmaError" do
        expect { subject }.to raise_error(
          Hanami::DB::SQLite::UnknownPragmaError,
          /frobnicate/,
        )
      end

      it "lists every unknown name when multiple are given" do
        multi_args = {overrides: {frobnicate: 1, wibble: 2}}
        expect { described_class.new(**multi_args) }.to raise_error(
          Hanami::DB::SQLite::UnknownPragmaError,
        ) { |e| expect(e.unknown).to contain_exactly(:frobnicate, :wibble) }
      end
    end

    context "with a known override pragma name" do
      let(:args) { {overrides: {temp_store: "memory"}} }

      it "does not raise" do
        expect { subject }.not_to raise_error
      end
    end

    context "with clear_defaults: true and an unknown override" do
      let(:args) { {clear_defaults: true, overrides: {frobnicate: 1}} }

      it "still raises UnknownPragmaError" do
        expect { subject }.to raise_error(
          Hanami::DB::SQLite::UnknownPragmaError,
          /frobnicate/,
        )
      end
    end

  end

  describe ".names" do
    let(:fake_db) { instance_double(SQLite3::Database, execute: [["foreign_keys"]], close: nil) }

    before { described_class.instance_variable_set(:@names, nil) }
    after { described_class.instance_variable_set(:@names, nil) }

    it "opens the :memory: connection only once across many validations" do
      allow(SQLite3::Database).to receive(:new).and_return(fake_db)

      3.times { described_class.new(clear_defaults: true, overrides: {foreign_keys: 1}) }

      expect(SQLite3::Database).to have_received(:new).once
    end
  end

  describe "#connect_sqls" do
    let(:args) { {overrides: {synchronous: :full}} }

    it "returns one `PRAGMA name = value` statement per resolved pragma" do
      expect(subject.connect_sqls).to contain_exactly(
        *subject.to_h.map { |name, value| "PRAGMA #{name} = #{value}" },
      )
    end

    it "interpolates overridden values" do
      expect(subject.connect_sqls).to include("PRAGMA synchronous = full")
    end

    it "preserves the resolved insertion order" do
      expect(subject.connect_sqls.first).to eq("PRAGMA foreign_keys = true")
    end
  end
end
