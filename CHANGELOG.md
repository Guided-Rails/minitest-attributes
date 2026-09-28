# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `assert_hash_attributes(hash, **expected)` assertion, applying the same comparisons to hash values
  - Keys are looked up as given, then as strings, so symbol keys match parsed JSON
  - A missing key fails, even when the expected value is `nil`

## [0.1.0] - 2026-09-24

### Added

- `assert_attributes(record, **expected)` assertion, mixed into `Minitest::Assertions` on require
  - `nil` expectations use `assert_nil`
  - `Time` expectations are compared within a one second delta
  - Actual values responding to `to_plain_text` (e.g. Action Text rich text) are compared as plain text
