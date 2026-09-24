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
  module Attributes
    TIME_DELTA = 1

    def assert_attributes(record, **expected_attributes)
      expected_attributes.each do |attribute, expected_value|
        assert_attribute(record, attribute, expected_value)
      end
    end

    private

    def assert_attribute(record, attribute, expected_value)
      actual_value = record.public_send(attribute)

      if expected_value.nil?
        assert_nil(
          actual_value,
          attribute_message(record, attribute, expected_value, actual_value)
        )
      elsif expected_value.is_a?(Time)
        assert_in_delta(
          expected_value.to_f,
          actual_value.to_f,
          TIME_DELTA,
          attribute_message(record, attribute, expected_value, actual_value)
        )
      elsif actual_value.respond_to?(:to_plain_text)
        plain_actual_value = actual_value.to_plain_text
        assert_equal(
          expected_value,
          plain_actual_value,
          attribute_message(
            record, attribute, expected_value, plain_actual_value
          )
        )
      else
        assert_equal(
          expected_value,
          actual_value,
          attribute_message(record, attribute, expected_value, actual_value)
        )
      end
    end

    def attribute_message(record, attribute, expected_value, actual_value)
      "Expected #{record.class.name}##{attribute} to be " \
        "#{expected_value.inspect}, but was #{actual_value.inspect}"
    end
  end

  Assertions.include(Attributes)
end
