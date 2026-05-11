# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Break Versioning](https://www.taoensso.com/break-versioning).

## [Unreleased]

### Added

- `Hanami::DB::SQLite::Pragmas` — a value class holding a set of SQLite
  pragmas with sensible defaults, user overrides, and validation against
  `PRAGMA pragma_list`. Exposes `#connect_sqls`, an array of `PRAGMA`
  statements suitable for Sequel's per-connection `connect_sqls` option.
  `UnknownPragmaError` is raised when an override names a pragma the
  linked SQLite doesn't recognise.

### Changed

### Deprecated

### Removed

### Fixed

### Security

[Unreleased]: https://github.com/hanami/hanami-db/compare/v2.3.0...main

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
