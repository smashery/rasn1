# frozen_string_literal: true

module RASN1
  module Types
    # ASN.1 Null
    # @author Sylvain Daubert
    class Null < Primitive
      # Null tag value
      TAG = 0x05

      # @return [String]
      def inspect(level=0)
        str = common_inspect(level)[0..-2] # remove terminal ':'
        str << ' OPTIONAL' if optional?
        str
      end

      private

      def value_to_der
        ''
      end

      def der_to_value(der, ber: false)
        raise ASN1Error, 'NULL TAG should not have content!' if der.length.positive?

        @value = nil
      end
    end
  end
end
