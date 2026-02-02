# frozen_string_literal: true

require "pathname"
require "hanami-db"

SPEC_ROOT = Pathname(__dir__).realpath.freeze

require_relative "support/rspec"
SPEC_ROOT.glob("support/**/*.rb").each { |f| require(f) }
