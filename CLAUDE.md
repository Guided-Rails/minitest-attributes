# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is minitest-attributes

A small Minitest extension providing `assert_attributes(record, **expected)`: read each attribute with `public_send` and assert it equals the expected value, with special handling for `nil`, `Time`, and rich text. Extracted from the Catberry Rails app's test helpers. Minitest is the only runtime dependency; there is no Rails or ActiveSupport dependency, so keep it that way (duck-type instead of referencing Rails constants).

## Commands

```bash
bundle exec rake                                                            # Tests + RuboCop
bundle exec rake test                                                       # Tests only
bundle exec ruby -Ilib:test test/minitest/test_attributes.rb -n test_name   # Single test
bundle exec rake rubocop                                                    # Lint only
```

## Architecture

- `lib/minitest/attributes.rb` — the `Minitest::Attributes` module and the `Minitest::Assertions.include` that makes it available everywhere on require
- `lib/minitest/attributes/version.rb` — `VERSION`
- `sig/minitest/attributes.rbs` — RBS signatures
- `test/minitest/test_attributes.rb` — tests, using plain `Struct`s as records

## Code style

RuboCop with double quotes and 80 column lines. Tests build their objects inline rather than in `setup`.
