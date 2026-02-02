# frozen_string_literal: true

source "https://rubygems.org"

eval_gemfile "Gemfile.devtools"

gemspec

gem "hanami-devtools", github: "hanami/devtools", branch: "main"

gem "sqlite3"

group :docs do
  gem "redcarpet", platforms: :mri
  gem "yard"
  gem "ostruct" # for yard
end
