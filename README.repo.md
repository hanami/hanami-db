## Installation

Add this line to your Hanami application's Gemfile:

```ruby
gem "hanami-db"
```

And then execute:

```shell
$ bundle
```

## Development

Most of the test suite runs against SQLite and needs no setup. The specs that exercise Postgres and
MySQL need those servers running, which `docker compose` provides:

```shell
$ docker compose up -d
$ bundle exec rspec
```

Postgres listens on 5433 and MySQL on 3307 locally, so they don't collide with any servers you
already have installed. CI uses the default ports; override with `POSTGRES_BASE_URL` if your setup
differs.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
