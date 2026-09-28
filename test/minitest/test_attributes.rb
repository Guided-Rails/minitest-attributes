# frozen_string_literal: true

require "test_helper"

module Minitest
  class TestAttributes < Minitest::Test
    Person = Struct.new(:first_name, :last_name, :born_at, :bio, :nickname)

    RichText = Struct.new(:html) do
      def to_plain_text
        html.gsub(/<[^>]+>/, "")
      end
    end

    def test_that_it_has_a_version_number
      refute_nil(::Minitest::Attributes::VERSION)
    end

    def test_is_mixed_into_minitest_assertions
      assert_includes(Minitest::Assertions.ancestors, Minitest::Attributes)
    end

    def test_passes_when_every_attribute_matches
      person = Person.new("Marceline", "Abadeer")

      assert_attributes(person, first_name: "Marceline", last_name: "Abadeer")
    end

    def test_passes_with_no_expected_attributes
      person = Person.new("Marceline", "Abadeer")

      assert_attributes(person)
    end

    def test_fails_with_a_descriptive_message_on_mismatch
      person = Person.new("Marceline", "Abadeer")

      error = assert_raises(Minitest::Assertion) do
        assert_attributes(person, first_name: "Marceline", last_name: "Bubblegum")
      end

      assert_match(
        /Expected Minitest::TestAttributes::Person#last_name to be "Bubblegum", but was "Abadeer"/,
        error.message
      )
    end

    def test_passes_when_expected_nil_and_actual_nil
      person = Person.new("Marceline", "Abadeer", nil, nil, nil)

      assert_attributes(person, nickname: nil)
    end

    def test_fails_when_expected_nil_and_actual_present
      person = Person.new("Marceline", "Abadeer", nil, nil, "Marcy")

      error = assert_raises(Minitest::Assertion) do
        assert_attributes(person, nickname: nil)
      end

      assert_match(
        /Expected Minitest::TestAttributes::Person#nickname to be nil, but was "Marcy"/,
        error.message
      )
    end

    def test_passes_when_time_is_within_delta
      born_at = Time.utc(2000, 1, 1, 12, 0, 0)
      person = Person.new("Marceline", "Abadeer", born_at + 0.5)

      assert_attributes(person, born_at:)
    end

    def test_fails_when_time_is_outside_delta
      born_at = Time.utc(2000, 1, 1, 12, 0, 0)
      person = Person.new("Marceline", "Abadeer", born_at + 2)

      error = assert_raises(Minitest::Assertion) do
        assert_attributes(person, born_at:)
      end

      assert_match(/Expected Minitest::TestAttributes::Person#born_at to be 2000-01-01 12:00:00 UTC/, error.message)
    end

    def test_fails_when_time_is_expected_but_actual_is_nil
      born_at = Time.utc(2000, 1, 1, 12, 0, 0)
      person = Person.new("Marceline", "Abadeer", nil)

      error = assert_raises(Minitest::Assertion) do
        assert_attributes(person, born_at:)
      end

      assert_match(/but was nil/, error.message)
    end

    def test_compares_rich_text_as_plain_text
      person = Person.new("Marceline", "Abadeer", nil, RichText.new("<p>Vampire Queen</p>"))

      assert_attributes(person, bio: "Vampire Queen")
    end

    def test_fails_on_rich_text_mismatch_with_plain_text_in_message
      person = Person.new("Marceline", "Abadeer", nil, RichText.new("<p>Vampire Queen</p>"))

      error = assert_raises(Minitest::Assertion) do
        assert_attributes(person, bio: "Bass Player")
      end

      assert_match(
        /Expected Minitest::TestAttributes::Person#bio to be "Bass Player", but was "Vampire Queen"/,
        error.message
      )
    end

    def test_reports_the_first_mismatch_only
      person = Person.new("Marceline", "Abadeer")

      error = assert_raises(Minitest::Assertion) do
        assert_attributes(person, first_name: "Finn", last_name: "Mertens")
      end

      assert_match(/#first_name/, error.message)
      refute_match(/#last_name/, error.message)
    end

    def test_raises_when_attribute_does_not_exist
      person = Person.new("Marceline", "Abadeer")

      assert_raises(NoMethodError) do
        assert_attributes(person, middle_name: "the")
      end
    end

    def test_hash_passes_when_every_symbol_key_matches
      hash = { first_name: "Marceline", last_name: "Abadeer" }

      assert_hash_attributes(hash, first_name: "Marceline", last_name: "Abadeer")
    end

    def test_hash_passes_when_every_string_key_matches
      hash = { "@type" => "Person", "first_name" => "Marceline" }

      assert_hash_attributes(hash, "@type": "Person", first_name: "Marceline")
    end

    def test_hash_passes_with_no_expected_attributes
      assert_hash_attributes({})
    end

    def test_hash_prefers_the_key_as_given_over_its_string_form
      hash = { first_name: "Marceline", "first_name" => "Finn" }

      assert_hash_attributes(hash, first_name: "Marceline")
    end

    def test_hash_fails_with_a_descriptive_message_on_mismatch
      hash = { "first_name" => "Marceline", "last_name" => "Abadeer" }

      error = assert_raises(Minitest::Assertion) do
        assert_hash_attributes(hash, first_name: "Marceline", last_name: "Bubblegum")
      end

      assert_match(
        /Expected hash\["last_name"\] to be "Bubblegum", but was "Abadeer"/,
        error.message
      )
    end

    def test_hash_fails_when_key_is_missing
      hash = { "first_name" => "Marceline" }

      error = assert_raises(Minitest::Assertion) do
        assert_hash_attributes(hash, middle_name: "the")
      end

      assert_match(
        /Expected hash to have key :middle_name, but its keys were \["first_name"\]/,
        error.message
      )
    end

    def test_hash_passes_when_expected_nil_and_actual_nil
      hash = { "nickname" => nil }

      assert_hash_attributes(hash, nickname: nil)
    end

    def test_hash_fails_when_expected_nil_and_actual_present
      hash = { "nickname" => "Marcy" }

      error = assert_raises(Minitest::Assertion) do
        assert_hash_attributes(hash, nickname: nil)
      end

      assert_match(
        /Expected hash\["nickname"\] to be nil, but was "Marcy"/,
        error.message
      )
    end

    def test_hash_fails_when_expected_nil_and_key_is_missing
      hash = {}

      error = assert_raises(Minitest::Assertion) do
        assert_hash_attributes(hash, nickname: nil)
      end

      assert_match(/Expected hash to have key :nickname/, error.message)
    end

    def test_hash_passes_when_time_is_within_delta
      born_at = Time.utc(2000, 1, 1, 12, 0, 0)
      hash = { born_at: born_at + 0.5 }

      assert_hash_attributes(hash, born_at:)
    end

    def test_hash_fails_when_time_is_outside_delta
      born_at = Time.utc(2000, 1, 1, 12, 0, 0)
      hash = { born_at: born_at + 2 }

      error = assert_raises(Minitest::Assertion) do
        assert_hash_attributes(hash, born_at:)
      end

      assert_match(/Expected hash\[:born_at\] to be 2000-01-01 12:00:00 UTC/, error.message)
    end

    def test_hash_compares_rich_text_as_plain_text
      hash = { bio: RichText.new("<p>Vampire Queen</p>") }

      assert_hash_attributes(hash, bio: "Vampire Queen")
    end

    def test_hash_fails_on_rich_text_mismatch_with_plain_text_in_message
      hash = { bio: RichText.new("<p>Vampire Queen</p>") }

      error = assert_raises(Minitest::Assertion) do
        assert_hash_attributes(hash, bio: "Bass Player")
      end

      assert_match(
        /Expected hash\[:bio\] to be "Bass Player", but was "Vampire Queen"/,
        error.message
      )
    end
  end
end
