# frozen_string_literal: true

require "rom"
require "rom-sql"
require "zeitwerk"

module Hanami
  module DB
    require_relative "db/gem_inflector"
    require_relative "db/errors"

    # @api private
    # @since 2.2.0
    def self.loader
      @loader ||= Zeitwerk::Loader.new.tap do |loader|
        root = File.expand_path("..", __dir__)

        loader.inflector = GemInflector.new("#{root}/hanami/db.rb")
        loader.tag = "hanami-db"
        loader.push_dir root
        loader.ignore(
          "#{root}/hanami-db.rb",
          "#{root}/hanami/db/gem_inflector.rb",
          "#{root}/hanami/db/errors.rb"
        )
      end
    end
    loader.setup
  end
end
