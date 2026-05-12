# frozen_string_literal: true

RSpec.describe Hanami::DB::SQLite::UnknownPragmaError do
  subject { described_class.new(unknown_pragmas) }

  let(:unknown_pragmas) { [:frobnicate, :wibble] }

  it "is a StandardError" do
    expect(subject).to be_a(StandardError)
  end

  it "lists the unknown pragma names in the message" do
    expect(subject.message).to include("frobnicate")
    expect(subject.message).to include("wibble")
  end

  it "exposes the unknown pragma names" do
    expect(subject.unknown).to eq([:frobnicate, :wibble])
  end

  it "exposes a frozen copy of the unknown pragma names" do
    expect(subject.unknown).to be_frozen
  end

  context "with a single unknown pragma" do
    subject { described_class.new([:frobnicate]) }

    it "formats the name plainly in the message" do
      expect(subject.message).to include("frobnicate")
    end

    it "does not render the names as an inspected array" do
      expect(subject.message).not_to include("[:frobnicate]")
    end
  end
end
