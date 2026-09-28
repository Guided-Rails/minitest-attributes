# Minitest::Attributes

Assert several attributes of an object in one call, with a clear failure message for the first mismatch.

```ruby
assert_attributes(
  person,
  first_name: "Marceline",
  last_name: "Abadeer",
  nickname: nil,
  created_at: Time.current,
  bio: "Vampire Queen"
)
```

## Installation

Add the gem to your application's Gemfile in the test group:

```ruby
gem "minitest-attributes", group: :test
```

Then run:

```bash
bundle install
```

Requiring the gem mixes `assert_attributes` and `assert_hash_attributes` into `Minitest::Assertions`, so it is available in every `Minitest::Test`, `ActiveSupport::TestCase`, and integration test. Bundler requires it for you in a Rails app; otherwise add `require "minitest/attributes"` to your test helper.

## Usage

Each key is read from the object with `public_send` and compared with its expected value:

- A `nil` expectation uses `assert_nil`.
- A `Time` expectation (including `ActiveSupport::TimeWithZone`) is compared within a one second tolerance, so `Time.current` is safe to use as an expected value.
- An actual value that responds to `to_plain_text`, such as an Action Text rich text, is compared as plain text.
- Everything else uses `assert_equal`.

A mismatch fails with a message such as:

```
Expected Person#last_name to be "Bubblegum", but was "Abadeer"
```

### Hashes

`assert_hash_attributes` makes the same comparisons against the values of a hash. Each key is looked up as given and then as a string, so symbol keys also match parsed JSON:

```ruby
assert_hash_attributes(
  JSON.parse(response.body),
  "@type": "Person",
  name: "Marceline",
  nickname: nil
)
```

A missing key fails with the hash's keys, even when the expected value is `nil`:

```
Expected hash to have key :nickname, but its keys were ["@type", "name"]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then run `bundle exec rake` to run the tests and RuboCop. You can also run `bin/console` for an interactive prompt.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Guided-Rails/minitest-attributes. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/Guided-Rails/minitest-attributes/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Minitest::Attributes project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Guided-Rails/minitest-attributes/blob/main/CODE_OF_CONDUCT.md).
