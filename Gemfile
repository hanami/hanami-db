# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "hanami-devtools", github: "hanami/devtools", branch: "main"

group :development do
  gem "rake"
  gem "rubocop"
end

gem "sqlite3"

group :docs do
  gem "redcarpet", platforms: :mri
  gem "yard"
  gem "ostruct" # for yard
end
