# frozen_string_literal: true

RSpec.describe Hanami::DB::Relation do
  let :adapters do
    {
      default: [:sql, "sqlite::memory"],
      alternate: [:memory, "memory://test"]
    }
  end

  let!(:config) { ROM::Configuration.new(adapters) }

  before do
    module Test
      class User < Hanami::DB::Relation
        schema(:users) {}
      end

      class APITokens < Hanami::DB::Relation[:memory]
        schema(:api_tokens) {}
      end
    end

    config.register_relation Test::User
    config.register_relation Test::APITokens
  end

  subject(:rom) { ROM.container(config) }

  context "no adapter specified" do
    subject(:relation) { rom.relations[:users] }

    it "chooses the default" do
      expect(relation.adapter).to eq :sql
    end
  end

  context "adapter is specified" do
    subject(:relation) { rom.relations[:api_tokens] }

    it "chooses the given adapter" do
      expect(relation.adapter).to eq :memory
    end
  end
end
