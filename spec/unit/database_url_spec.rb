# frozen_string_literal: true

RSpec.describe Hanami::DB::DatabaseURL do
  describe ".jdbc?" do
    it "is true for JDBC URLs" do
      expect(described_class.jdbc?("jdbc:postgresql://localhost/app")).to be true
    end

    it "is false for other URLs" do
      expect(described_class.jdbc?("postgres://localhost/app")).to be false
    end

    it "accepts any #to_s object such as URI" do
      expect(described_class.jdbc?(URI("jdbc:sqlite:db/app.sqlite3"))).to be true
    end
  end

  describe ".uri" do
    it "parses URLs" do
      uri = described_class.uri("postgres://user:pass@localhost:5432/app")

      expect(uri).to have_attributes(scheme: "postgres", user: "user", host: "localhost", path: "/app")
    end

    it "parses the URL nested in a JDBC URL" do
      uri = described_class.uri("jdbc:postgresql://localhost:5432/app?user=postgres")

      expect(uri).to have_attributes(scheme: "postgresql", host: "localhost", path: "/app", query: "user=postgres")
    end

    it "parses single-colon JDBC URLs" do
      uri = described_class.uri("jdbc:sqlite:db/app.sqlite3")

      expect(uri).to have_attributes(scheme: "sqlite", opaque: "db/app.sqlite3")
    end

    it "raises an error for URLs that cannot be parsed, without including the URL's credentials" do
      expect { described_class.uri("postgres://user:se cret@localhost/app") }
        .to raise_error(Hanami::DB::InvalidDatabaseURLError) { |error|
          expect(error.message).to start_with "`postgres' database URL could not be parsed"
          expect(error.message).not_to include "cret"
          expect(error.cause).to be_nil
        }
    end

    it "includes the JDBC subprotocol in the error for JDBC URLs that cannot be parsed" do
      expect { described_class.uri("jdbc:postgresql://user:se cret@localhost/app") }
        .to raise_error(Hanami::DB::InvalidDatabaseURLError, /\A`jdbc:postgresql' database URL/)
    end
  end

  describe ".scheme" do
    {
      "postgres://user:secret@localhost/app" => "postgres",
      "jdbc:postgresql://localhost/app" => "jdbc:postgresql",
      "jdbc:sqlite:db/app.sqlite3" => "jdbc:sqlite",
      "jdbc:sqlserver://localhost;user=sa;password=secret" => "jdbc:sqlserver",
      "postgres://user:se cret@localhost/app" => "postgres"
    }.each do |url, scheme|
      it "is #{scheme.inspect} for #{url}" do
        expect(described_class.scheme(url)).to eq scheme
      end
    end

    it "is nil for URLs without a scheme" do
      expect(described_class.scheme("db/app.sqlite3")).to be_nil
    end
  end

  describe ".adapter" do
    {
      "sqlite://db/app.sqlite3" => :sqlite,
      "jdbc:sqlite:db/app.sqlite3" => :sqlite,
      "jdbc:sqlite::memory:" => :sqlite,
      "postgres://localhost/app" => :postgres,
      "postgresql://localhost/app" => :postgres,
      "jdbc:postgresql://localhost/app" => :postgres,
      "jdbc:postgresql:app" => :postgres,
      "mysql://localhost/app" => :mysql,
      "mysql2://localhost/app" => :mysql,
      "jdbc:mysql://localhost/app" => :mysql
    }.each do |url, adapter|
      it "is #{adapter.inspect} for #{url}" do
        expect(described_class.adapter(url)).to eq adapter
      end
    end

    it "is nil for unsupported schemes" do
      expect(described_class.adapter("oracle://localhost/app")).to be_nil
      expect(described_class.adapter("jdbc:sqlserver://localhost;databaseName=app")).to be_nil
    end

    it "is nil for JDBC subprotocols that JDBC drivers do not accept" do
      expect(described_class.adapter("jdbc:postgres://localhost/app")).to be_nil
      expect(described_class.adapter("jdbc:mysql2://localhost/app")).to be_nil
    end

    it "is nil for unparseable URLs" do
      expect(described_class.adapter("not a url")).to be_nil
    end
  end

  describe ".gem_name" do
    {
      "sqlite://db/app.sqlite3" => "sqlite3",
      "postgres://localhost/app" => "pg",
      "postgresql://localhost/app" => "pg",
      "mysql2://localhost/app" => "mysql2",
      "jdbc:sqlite:db/app.sqlite3" => "jdbc-sqlite3",
      "jdbc:postgresql://localhost/app" => "jdbc-postgres",
      "jdbc:mysql://localhost/app" => "jdbc-mysql"
    }.each do |url, gem_name|
      it "is #{gem_name} for #{url}" do
        expect(described_class.gem_name(url)).to eq gem_name
      end
    end

    it "is nil for unsupported schemes" do
      expect(described_class.gem_name("oracle://localhost/app")).to be_nil
    end

    it "is nil for the mysql scheme, which Sequel connects to using the mysql gem" do
      expect(described_class.gem_name("mysql://localhost/app")).to be_nil
    end

    it "is nil for JDBC subprotocols that JDBC drivers do not accept" do
      expect(described_class.gem_name("jdbc:postgres://localhost/app")).to be_nil
      expect(described_class.gem_name("jdbc:mysql2://localhost/app")).to be_nil
    end

    it "is nil for unparseable URLs" do
      expect(described_class.gem_name("not a url")).to be_nil
    end
  end
end
