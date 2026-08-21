# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Break Versioning](https://www.taoensso.com/break-versioning).

## [Unreleased]

### Added

### Changed

### Deprecated

### Removed

### Fixed

- `Hanami::DB::Testing.database_url` now transforms `jdbc:` database URLs. Previously it returned them
  unchanged, so with `HANAMI_ENV=test` the test database URL still pointed at the **development**
  database, and running the test suite truncated or migrated development data. This affected JRuby
  applications, which are the only ones that must use `jdbc:` URLs.

  The `jdbc:postgresql:`, `jdbc:mysql:` and `jdbc:sqlite:` subprotocols are transformed, in both the
  `jdbc:sqlite://db/app.db` and single-colon `jdbc:sqlite:db/app.db` forms, including SQLite's
  Windows drive-letter (`jdbc:sqlite:C:/db/app.db`) and `file:` URI filename
  (`jdbc:sqlite:file:db/app.db?mode=ro`) paths. Other subprotocols — `jdbc:sqlserver:`, `jdbc:h2:`,
  `jdbc:derby:` and the rest — name their databases in ways this transformation does not understand,
  and continue to be returned untouched. In-memory SQLite databases (`sqlite::memory:`,
  `jdbc:sqlite:file::memory:?cache=private`, `jdbc:sqlite:file:app?mode=memory`) are also left alone.
- `Hanami::DB::Testing.database_url` now transforms the single-colon `sqlite:db/development.sqlite3`
  form on CRuby too, not only behind a `jdbc:` prefix. Previously it was returned unchanged.

### Security

[Unreleased]: https://github.com/hanami/hanami-db/compare/v3.0.0...main

## [3.0.0] - 2026-06-30

### Changed

- Require Ruby 3.3 or newer.

[3.0.0]: https://github.com/hanami/hanami-db/compare/v2.3.0...3.0.0

## [3.0.0.rc1] - 2026-06-16

### Changed

- Require Ruby 3.3 or newer.

[3.0.0.rc1]: https://github.com/hanami/hanami-db/compare/v2.3.0...3.0.0.rc1

## [2.3.0] - 2025-11-12

### Changed

- Drop support for Ruby 3.1

[2.3.0]: https://github.com/hanami/hanami-db/compare/v2.3.0.beta2...v2.3.0

## [2.3.0.beta2] - 2025-10-17

### Changed

- Drop support for Ruby 3.1

[2.3.0.beta2]: https://github.com/hanami/db/compare/v2.3.0.beta1...v2.3.0.beta2

## [2.3.0.beta1] - 2025-10-03

[2.3.0.beta1]: https://github.com/hanami/db/compare/v2.2.1...v2.3.0.beta1

## [2.2.1] - 2025-01-10

### Fixed

- Update for compatibility with latest rom and rom-sql releases. (@flash-gordon in #16)

[2.2.1]: https://github.com/hanami/db/compare/v2.2.0...v2.2.1

## [2.2.0] - 2024-10-29

[2.2.0]: https://github.com/hanami/db/compare/v2.2.0.rc1...v2.2.0

## [2.2.0.rc1] - 2024-10-29

### Added

- Add `Hanami::DB::Struct#to_json`. (@krzykamil in #13)

[2.2.0.rc1]: https://github.com/hanami/db/compare/v2.2.0.beta2...v2.2.0.rc1

## [2.2.0.beta2] - 2024-09-25

[2.2.0.beta2]: https://github.com/hanami/db/compare/v2.2.0.beta1...v2.2.0.beta2

## [2.2.0.beta1] - 2024-07-16

### Added

- Initial release.

[2.2.0.beta1]: https://github.com/hanami/db/releases/tag/v2.2.0.beta1
