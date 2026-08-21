# frozen_string_literal: true

RSpec.describe Hanami::DB::Testing do
  subject { described_class.method(:database_url) }

  shared_examples "URL Transforms" do |scheme|
    define_method(:url) { |path| URI.join("#{scheme}://localhost", path).to_s }

    it "transforms _dev to _test" do
      expect(subject.call(url("/bookshelf_dev"))).to eq url("/bookshelf_test")
    end

    it "transforms _development to _test" do
      expect(subject.call(url("/bookshelf_development"))).to eq url("/bookshelf_test")
    end

    it "does not transform _test" do
      expect(subject.call(url("/bookshelf_test"))).to eq url("/bookshelf_test")
    end

    it "appends to non-conforming paths" do
      expect(subject.call(url("/bookshelf_database"))).to eq url("/bookshelf_database_test")
    end

    it "accepts any #to_s object such as URI" do
      url = URI("#{scheme}://localhost:5432/bookshelf_development")
      expect(subject.call(url)).to eq "#{scheme}://localhost:5432/bookshelf_test"
    end
  end

  context "postgres scheme" do
    include_examples "URL Transforms", :postgres

    it "preserves query params" do
      url = "postgres://user:pass@/bookshelf_development?host=/var/run/postgresql/.s.PGSQL.5432"
      expect(subject.call(url)).to eq "postgres://user:pass@/bookshelf_test?host=/var/run/postgresql/.s.PGSQL.5432"
    end
  end

  context "postgresql scheme" do
    include_examples "URL Transforms", :postgresql

    it "preserves query params" do
      url = "postgresql://user:pass@/bookshelf_dev?host=/var/run/postgresql/.s.PGSQL.5432"
      expect(subject.call(url)).to eq "postgresql://user:pass@/bookshelf_test?host=/var/run/postgresql/.s.PGSQL.5432"
    end
  end

  context "mysql scheme" do
    include_examples "URL Transforms", :mysql
  end

  context "sqlite scheme" do
    it "transforms _dev.db to _test.db" do
      url = "sqlite://./config/bookshelf_dev.db"
      expect(subject.call(url)).to eq "sqlite://./config/bookshelf_test.db"
    end

    it "transforms _development.db to _test.db" do
      url = "sqlite:///app/config/bookshelf_development.db"
      expect(subject.call(url)).to eq "sqlite:///app/config/bookshelf_test.db"
    end

    it "does not transform _test.db" do
      url = "sqlite://./config/bookshelf_test.db"
      expect(subject.call(url)).to eq "sqlite://./config/bookshelf_test.db"
    end

    it "appends to non-conforming filenames" do
      url = "sqlite:///app/config/bookshelf.db"
      expect(subject.call(url)).to eq "sqlite:///app/config/bookshelf_test.db"
    end

    it "ignores non-hierarchical databases" do
      url = "sqlite::memory"
      expect(subject.call(url)).to eq "sqlite::memory"
    end

    it "transforms a single-colon relative path" do
      url = "sqlite:db/development.sqlite3"
      expect(subject.call(url)).to eq "sqlite:db/test.sqlite3"
    end

    it "transforms a single-colon _dev filename" do
      expect(subject.call("sqlite:app_dev.db")).to eq "sqlite:app_test.db"
    end

    it "ignores a single-colon in-memory database" do
      url = "sqlite:file::memory:?cache=shared"
      expect(subject.call(url)).to eq url
    end
  end

  context "jdbc prefix" do
    context "postgresql scheme" do
      it "transforms _development to _test" do
        expect(subject.call("jdbc:postgresql://h/app_development")).to eq "jdbc:postgresql://h/app_test"
      end

      it "transforms _dev to _test" do
        expect(subject.call("jdbc:postgresql://h/app_dev")).to eq "jdbc:postgresql://h/app_test"
      end

      it "appends to non-conforming paths" do
        expect(subject.call("jdbc:postgresql://h/app")).to eq "jdbc:postgresql://h/app_test"
      end

      it "does not transform _test" do
        expect(subject.call("jdbc:postgresql://h/app_test")).to eq "jdbc:postgresql://h/app_test"
      end

      it "accepts any #to_s object such as URI" do
        url = URI("jdbc:postgresql://localhost:5432/bookshelf_development")
        expect(subject.call(url)).to eq "jdbc:postgresql://localhost:5432/bookshelf_test"
      end
    end

    context "mysql scheme" do
      it "transforms _development to _test, preserving the port" do
        expect(subject.call("jdbc:mysql://h:3306/app_development")).to eq "jdbc:mysql://h:3306/app_test"
      end

      it "transforms _dev to _test" do
        expect(subject.call("jdbc:mysql://h:3306/app_dev")).to eq "jdbc:mysql://h:3306/app_test"
      end

      it "does not transform _test" do
        expect(subject.call("jdbc:mysql://h:3306/app_test")).to eq "jdbc:mysql://h:3306/app_test"
      end

      it "appends to non-conforming paths" do
        expect(subject.call("jdbc:mysql://h:3306/app")).to eq "jdbc:mysql://h:3306/app_test"
      end
    end

    context "sqlite scheme" do
      it "transforms a hierarchical path" do
        expect(subject.call("jdbc:sqlite://db/app.sqlite3")).to eq "jdbc:sqlite://db/app_test.sqlite3"
      end

      it "transforms an absolute opaque path" do
        expect(subject.call("jdbc:sqlite:/abs/bookshelf_dev.db")).to eq "jdbc:sqlite:/abs/bookshelf_test.db"
      end

      it "transforms a relative opaque path" do
        expect(subject.call("jdbc:sqlite:db/development.sqlite3")).to eq "jdbc:sqlite:db/test.sqlite3"
      end

      it "transforms a relative opaque path with a query string" do
        url = "jdbc:sqlite:db/development.sqlite3?journal_mode=WAL"
        expect(subject.call(url)).to eq "jdbc:sqlite:db/test.sqlite3?journal_mode=WAL"
      end

      it "transforms an opaque _development filename" do
        url = "jdbc:sqlite:db/app_development.sqlite3"
        expect(subject.call(url)).to eq "jdbc:sqlite:db/app_test.sqlite3"
      end

      it "appends to a non-conforming opaque filename" do
        expect(subject.call("jdbc:sqlite:db/app.sqlite3")).to eq "jdbc:sqlite:db/app_test.sqlite3"
      end

      it "does not transform an already-_test opaque path" do
        url = "jdbc:sqlite:db/app_test.sqlite3"
        expect(subject.call(url)).to eq "jdbc:sqlite:db/app_test.sqlite3"
      end

      it "transforms a Windows drive-letter opaque path" do
        url = "jdbc:sqlite:C:/data/app_development.db"
        expect(subject.call(url)).to eq "jdbc:sqlite:C:/data/app_test.db"
      end

      it "transforms an on-disk file: URI filename" do
        url = "jdbc:sqlite:file:db/app_development.db"
        expect(subject.call(url)).to eq "jdbc:sqlite:file:db/app_test.db"
      end

      it "transforms an on-disk file: URI filename with a query" do
        url = "jdbc:sqlite:file:data/sample.db?mode=ro"
        expect(subject.call(url)).to eq "jdbc:sqlite:file:data/sample_test.db?mode=ro"
      end
    end

    context "single-colon postgresql scheme" do
      it "transforms the host-less _development shorthand" do
        url = "jdbc:postgresql:bookshelf_development"
        expect(subject.call(url)).to eq "jdbc:postgresql:bookshelf_test"
      end

      it "appends to a non-conforming database name" do
        expect(subject.call("jdbc:postgresql:bookshelf")).to eq "jdbc:postgresql:bookshelf_test"
      end

      it "does not transform an already-_test database name" do
        url = "jdbc:postgresql:bookshelf_test"
        expect(subject.call(url)).to eq "jdbc:postgresql:bookshelf_test"
      end

      it "preserves a query string" do
        url = "jdbc:postgresql:bookshelf_dev?ssl=true"
        expect(subject.call(url)).to eq "jdbc:postgresql:bookshelf_test?ssl=true"
      end
    end

    describe "in-memory databases" do
      it "ignores the file: URI-filename form" do
        url = "jdbc:sqlite:file::memory:?cache=private"
        expect(subject.call(url)).to eq url
      end

      it "ignores the bare :memory: form" do
        expect(subject.call("jdbc:sqlite::memory:")).to eq "jdbc:sqlite::memory:"
      end

      it "ignores a named in-memory database" do
        url = "jdbc:sqlite:file:app?mode=memory"
        expect(subject.call(url)).to eq url
      end

      it "ignores a named shared-cache in-memory database" do
        url = "jdbc:sqlite:file:memdb1?mode=memory&cache=shared"
        expect(subject.call(url)).to eq url
      end

      it "ignores :memory: carrying a query string" do
        url = "jdbc:sqlite::memory:?cache=shared"
        expect(subject.call(url)).to eq url
      end
    end

    describe "round trip" do
      it "preserves credentials, port and query params" do
        url = "jdbc:postgresql://user:pass@localhost:5432/bookshelf_development?ssl=true"
        expect(subject.call(url)).to eq "jdbc:postgresql://user:pass@localhost:5432/bookshelf_test?ssl=true"
      end

      it "preserves a socket host query param" do
        url = "jdbc:postgresql://user:pass@/bookshelf_dev?host=/var/run/postgresql/.s.PGSQL.5432"
        expect(subject.call(url)).to eq(
          "jdbc:postgresql://user:pass@/bookshelf_test?host=/var/run/postgresql/.s.PGSQL.5432"
        )
      end
    end

    describe "unrecognised subprotocols" do
      # Only postgresql, mysql and sqlite name their databases in a way this
      # transformation understands. Everything else must round-trip untouched
      # rather than be mangled by the generic path branches.
      [
        "jdbc:h2:mem:test",
        "jdbc:h2:./db/development",
        "jdbc:derby:db/development",
        "jdbc:db2://h:50000/APPDEV",
        "jdbc:db2://host:50000/APPDEV:currentSchema=x;",
        "jdbc:as400://host/lib;naming=system",
        "jdbc:sqlserver://h;databaseName=bookshelf_development",
        "jdbc:informix-sqli://h:1533/app_development:INFORMIXSERVER=x"
      ].each do |url|
        it "leaves #{url} untouched" do
          expect(subject.call(url)).to eq url
        end
      end
    end

    describe "unparseable remainders" do
      # Stripping the prefix turns an always-parseable opaque URI into a
      # hierarchical one that URI can reject. Such URLs must keep no-opping,
      # not raise out of Hanami::Providers::DB#detect_database_urls_from_env.
      [
        "jdbc:sqlserver://localhost:1433;databaseName=app_development",
        "jdbc:postgresql://h1:5432,h2:5432/app_development",
        "jdbc:mysql://host1:3306,host2:3306/app_development",
        "jdbc:sqlite:",
        "jdbc:sqlite://",
        "jdbc:sqlite:?foo=bar"
      ].each do |url|
        it "returns #{url} unchanged without raising" do
          expect { subject.call(url) }.not_to raise_error
          expect(subject.call(url)).to eq url
        end
      end
    end
  end
end
