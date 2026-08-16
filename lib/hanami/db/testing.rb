# frozen_string_literal: true

require "pathname"
require "uri"

module Hanami
  module DB
    module Testing
      # Replaces development suffix in test mode
      #
      # @api private
      # @since 2.2.0
      DATABASE_NAME_SUFFIX = "_test"

      # @api private
      # @since 2.2.0
      DATABASE_NAME_MATCHER = /_dev(elopment)?$/
      private_constant :DATABASE_NAME_MATCHER

      # Prefix of the JDBC URLs that JRuby applications must use
      #
      # @api private
      # @since 3.0.1
      JDBC_PREFIX = "jdbc:"
      private_constant :JDBC_PREFIX

      # JDBC subprotocols whose URLs this transformation understands
      #
      # @api private
      # @since 3.0.1
      JDBC_SUBPROTOCOLS = ["postgresql:", "mysql:", "sqlite:"].freeze
      private_constant :JDBC_SUBPROTOCOLS

      # Prefix of a SQLite URI filename, e.g. "file:db/app.sqlite3?mode=ro"
      #
      # @api private
      # @since 3.0.1
      SQLITE_FILE_PREFIX = "file:"
      private_constant :SQLITE_FILE_PREFIX

      # Matches a SQLite in-memory database, which names no file on disk
      #
      # @api private
      # @since 3.0.1
      SQLITE_MEMORY_MATCHER = /\A:memory:?\z/
      private_constant :SQLITE_MEMORY_MATCHER

      # Marks a SQLite URI filename as in-memory, e.g. "file:app?mode=memory"
      #
      # @api private
      # @since 3.0.1
      SQLITE_MEMORY_QUERY = "mode=memory"
      private_constant :SQLITE_MEMORY_QUERY

      # Matches a SQLite filename, optionally led by a Windows drive letter.
      # Anchored, since a stray colon means an in-memory database.
      #
      # @api private
      # @since 3.0.1
      SQLITE_FILENAME_MATCHER = /\A([A-Za-z]:)?[^:]+\z/
      private_constant :SQLITE_FILENAME_MATCHER

      class << self
        # @api private
        # @since 2.2.0
        def database_url(url)
          url = url.to_s

          return jdbc_database_url(url) if url.start_with?(JDBC_PREFIX)

          # URI#dup does not duplicate internal instance
          # variables, making mutation dangerous.
          transform(URI(url))
        end

        private

        # Transform a JDBC URL by stripping its prefix, transforming the
        # remainder, then reattaching the prefix.
        #
        # Subprotocols we do not understand, and remainders URI cannot parse,
        # are returned untouched: mangling such a URL is worse than no-opping.
        #
        # @param url [String] JDBC database URL
        #
        # @return [String]
        #
        # @api private
        # @since 3.0.1
        def jdbc_database_url(url)
          rest = url.delete_prefix(JDBC_PREFIX)

          return url unless rest.start_with?(*JDBC_SUBPROTOCOLS)

          JDBC_PREFIX + transform(URI(rest))
        rescue URI::Error
          url
        end

        # Transform a parsed database URL into its test equivalent.
        #
        # @param url [URI] Database URL parsed as URI::Generic
        #
        # @return [String]
        #
        # @api private
        # @since 3.0.1
        def transform(url)
          case deconstruct_url(url)
          in {scheme: "sqlite", opaque: nil, path:} unless path.nil?
            url.path = database_filename(path)
          in {scheme: "sqlite", opaque: String => opaque, path: nil}
            url.opaque = sqlite_opaque(opaque)
          in {scheme: "postgres" | "postgresql" | "mysql", opaque: String => opaque, path: nil}
            url.opaque = database_opaque(opaque)
          in {path: String => path} if path =~ DATABASE_NAME_MATCHER
            url.path = path.sub(DATABASE_NAME_MATCHER, DATABASE_NAME_SUFFIX)
          in {path: String => path} unless path.end_with?(DATABASE_NAME_SUFFIX)
            url.path << DATABASE_NAME_SUFFIX
          else
            # do nothing
          end

          url.to_s
        end

        # Deconstructs a URI::Generic for pattern-matching.
        #
        # @param url [URI] Database URL parsed as URI::Generic
        #
        # @return [Hash]
        #
        # @api private
        # @since 2.2.0
        def deconstruct_url(url)
          %i[opaque path scheme].each_with_object({}) do |part, hash|
            hash[part] = url.public_send(part)
          end
        end

        # Transform database name as with URI paths, for single-colon URLs such
        # as "jdbc:postgresql:bookshelf_development", where URI parses the name
        # into #opaque rather than #path, with any query string folded in.
        #
        # @param opaque [String] opaque component from URI
        #
        # @return [String]
        #
        # @api private
        # @since 3.0.1
        def database_opaque(opaque)
          database, separator, query = opaque.partition("?")

          if database =~ DATABASE_NAME_MATCHER
            database = database.sub(DATABASE_NAME_MATCHER, DATABASE_NAME_SUFFIX)
          elsif !database.end_with?(DATABASE_NAME_SUFFIX)
            database += DATABASE_NAME_SUFFIX
          end

          database + separator + query
        end

        # Transform filename as with URI paths, for single-colon SQLite URLs
        # such as "jdbc:sqlite:db/development.sqlite3".
        #
        # SQLite spells its in-memory databases in this same component
        # (":memory:", "file::memory:?cache=private", "file:app?mode=memory").
        # Those name no file on disk, so they are returned untouched.
        #
        # @param opaque [String] opaque component from URI
        #
        # @return [String]
        #
        # @api private
        # @since 3.0.1
        def sqlite_opaque(opaque)
          location, separator, query = opaque.partition("?")
          prefix = location.start_with?(SQLITE_FILE_PREFIX) ? SQLITE_FILE_PREFIX : ""
          filename = location.delete_prefix(prefix)

          return opaque if filename.match?(SQLITE_MEMORY_MATCHER)
          return opaque if query.include?(SQLITE_MEMORY_QUERY)
          return opaque unless filename.match?(SQLITE_FILENAME_MATCHER)

          prefix + database_filename(filename) + separator + query
        end

        # Transform filename as with URI paths, but account for extname
        #
        # @param path [String] path component from URI
        #
        # @return [String]
        #
        # @api private
        # @since 2.2.0
        def database_filename(path)
          path = Pathname(path)
          ext = path.extname
          database = path.basename(ext).to_s

          if database =~ /^dev(elopment)?$/
            database = "test"
          elsif database =~ DATABASE_NAME_MATCHER
            database.sub!(DATABASE_NAME_MATCHER, DATABASE_NAME_SUFFIX)
          elsif !database.end_with?(DATABASE_NAME_SUFFIX)
            database << DATABASE_NAME_SUFFIX
          end

          path.dirname.join(database + ext).to_s
        end
      end
    end
  end
end
