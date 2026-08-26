# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

gemspec

gem "hanami-devtools", github: "hanami/devtools", branch: "main"

platforms :mri do
  gem "mysql2"
  gem "pg"
  gem "sqlite3"
end

platforms :jruby do
  gem "jdbc-mysql"
  gem "jdbc-postgres"
  gem "jdbc-sqlite3"
end

group :docs do
  gem "redcarpet", platforms: :mri
  gem "yard"
  gem "ostruct" # for yard
end
