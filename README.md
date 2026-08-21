<!--- This file is synced from hanakai-rb/repo-sync -->

[actions]: https://github.com/hanami/hanami-db/actions
[chat]: https://discord.gg/naQApPAsZB
[forum]: https://discourse.hanamirb.org
[rubygem]: https://rubygems.org/gems/hanami-db

# Hanami DB [![Gem Version](https://badge.fury.io/rb/hanami-db.svg)][rubygem] [![CI Status](https://github.com/hanami/hanami-db/workflows/CI/badge.svg)][actions]

[![Forum](https://img.shields.io/badge/Forum-dc360f?logo=discourse&logoColor=white)][forum]
[![Chat](https://img.shields.io/badge/Chat-717cf8?logo=discord&logoColor=white)][chat]

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
MySQL need those servers running, which `docker compose` provides. This needs
[Docker](https://docs.docker.com/get-started/get-docker/) installed: Docker Desktop on macOS and
Windows, or Docker Engine with the Compose plugin on Linux.

```shell
$ docker compose up -d
$ bundle exec rspec
```

Locally, Postgres listens on 5433 and MySQL on 3307, so they don't collide with any servers you
already have installed. CI runs Postgres on its default 5432 and MySQL on 3307. Override
`POSTGRES_BASE_URL` if your setup differs.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Links

- [User documentation](https://hanamirb.org)
- [API documentation](http://rubydoc.info/gems/hanami-db)


## License

See `LICENSE` file.

