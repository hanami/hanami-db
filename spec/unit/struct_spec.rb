# frozen_string_literal: true

RSpec.describe Hanami::DB::Struct do
  let!(:config) do
    ROM::Configuration.new(:sql, sqlite_memory_database_url) do |conf|
      conf.default.create_table(:users) do
        primary_key :id
        column :first_name, String
        column :last_name, String
      end

      conf.relation(:users) do
        schema(infer: true)
      end
    end
  end

  let(:rom) { ROM.container(config) }

  before do
    module Test
      module Entities
        class User < Hanami::DB::Struct
          def full_name
            "#{first_name} #{last_name}"
          end
        end
      end

      class UserRepo < ROM::Repository[:users]
        struct_namespace Entities
      end
    end
  end

  describe "#to_json" do
    before do
      rom.relations[:users].changeset(:create, id: 1, first_name: "L", last_name: "L").commit
    end

    it "converts to json" do
      repo = Test::UserRepo.new(rom)
      struct = repo.users.by_pk(1).one!
      expect(struct.full_name).to eq "L L"
      expect(struct.to_json).to eq "{\"id\":1,\"first_name\":\"L\",\"last_name\":\"L\"}"
    end
  end
end
