# frozen_string_literal: true

require "minitest"
require_relative "attributes/version"

# Minitest namespace. The gem's behavior lives in Minitest::Attributes.
module Minitest
  # Assertions for checking several attributes of one object at a time.
  #
  #   assert_attributes(person, first_name: "Marceline", last_name: "Abadeer")
  #
  # Each attribute is read with +public_send+ and compared to its expected
  # value. A +nil+ expectation uses +assert_nil+, a +Time+ expectation is
  # compared within +TIME_DELTA+ seconds, and an actual value that responds to
  # +to_plain_text+ (such as an Action Text rich text) is compared as plain
  # text. Everything else falls through to +assert_equal+.
  #
  # +assert_hash_attributes+ applies the same comparisons to the values of a
  # hash.
  module Attributes
    TIME_DELTA = 1

    def assert_attributes(record, **expected_attributes)
      expected_attributes.each do |attribute, expected_value|
        assert_value(
          "#{record.class.name}##{attribute}",
          expected_value,
          record.public_send(attribute)
        )
      end
    end

    # Like +assert_attributes+, but reads each key from a hash. A key is looked
    # up as given, then as a string, so symbol keys also match the string keys
    # of parsed JSON:
    #
    #   assert_hash_attributes(JSON.parse(body), "@type": "Person", age: 12)
    #
    # A missing key fails, even when the expected value is +nil+.
    def assert_hash_attributes(hash, **expected_attributes)
      expected_attributes.each do |key, expected_value|
        assert_hash_attribute(hash, key, expected_value)
      end
    end

    private

    def assert_hash_attribute(hash, key, expected_value)
      found_key = [key, key.to_s].find { |candidate| hash.key?(candidate) }
      assert(
        found_key,
        "Expected hash to have key #{key.inspect}, " \
        "but its keys were #{hash.keys.inspect}"
      )

      assert_value(
        "hash[#{found_key.inspect}]", expected_value, hash[found_key]
      )
    end

    def assert_value(label, expected_value, actual_value)
      if expected_value.nil?
        assert_nil(
          actual_value,
          value_message(label, expected_value, actual_value)
        )
      elsif expected_value.is_a?(Time)
        assert_in_delta(
          expected_value.to_f,
          actual_value.to_f,
          TIME_DELTA,
          value_message(label, expected_value, actual_value)
        )
      elsif actual_value.respond_to?(:to_plain_text)
        plain_actual_value = actual_value.to_plain_text
        assert_equal(
          expected_value,
          plain_actual_value,
          value_message(label, expected_value, plain_actual_value)
        )
      else
        assert_equal(
          expected_value,
          actual_value,
          value_message(label, expected_value, actual_value)
        )
      end
    end

    def value_message(label, expected_value, actual_value)
      "Expected #{label} to be " \
        "#{expected_value.inspect}, but was #{actual_value.inspect}"
    end
  end

  Assertions.include(Attributes)
end
