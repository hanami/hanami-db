# frozen_string_literal: true

require_relative "lib/hanami/db/version"

Gem::Specification.new do |spec|
  spec.name = "hanami-db"
  spec.version = Hanami::DB::VERSION
  spec.authors = ["Hanakai team"]
  spec.email = ["info@hanakai.org"]
  spec.summary = "The database layer for Hanami apps"
  spec.homepage = "https://hanamirb.org"
  spec.license = "MIT"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/hanami/db/issues",
    "changelog_uri" => "https://github.com/hanami/db/blob/main/CHANGELOG.md",
    "documentation_uri" => "https://guides.hanamirb.org",
    "funding_uri" => "https://github.com/sponsors/hanami",
    "source_code_uri" => "https://github.com/hanami/db",
    "rubygems_mfa_required" => "true"
  }

  spec.required_ruby_version = ">= 3.2"
  spec.add_dependency "rom", "~> 5.4", ">= 5.4.1"
  spec.add_dependency "rom-sql", "~> 3.7"
  spec.add_dependency "zeitwerk", "~> 2.6"

  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.files = Dir["*.gemspec", "lib/**/*"]
end
