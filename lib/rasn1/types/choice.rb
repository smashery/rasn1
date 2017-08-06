module RASN1
  module Types

    # A ASN.1 CHOICE is a choice between different types.
    #
    # == Create a CHOICE
    # A CHOICE is defined this way:
    #   choice = Choice.new(:a_choice)
    #   choice.value = [Integer.new(:int1, implicit: 0, class: :context),
    #                   Integer.new(:int2, implicit: 1, class: :context),
    #                   OctetString.new(:os, implicit: 2, class: :context)]
    # The chosen type may be set this way:
    #   choice.chosen = 0   # choose :int1
    # The chosen value may be set these ways:
    #   choise.value[choice.chosen].value = 1
    #   choise.set_chosen_value 1
    # The chosen value may be got these ways:
    #   choise.value[choice.chosen].value # => 1
    #   choice.chosen_value               # => 1
    #
    # == Encode a CHOICE
    # {#to_der} only encodes the chosen value:
    #   choise.to_der   # => "\x80\x01\x01"
    #
    # == Parse a CHOICE
    # Parsing a CHOICE set {#chosen} and set value to chosen type. If parsed string does
    # not contain a type from CHOICE, a {RASN1::ASN1Error} is raised.
    #   str = "\x04\x03abc"
    #   choice.parse! str
    #   choice.chosen        # => 2
    #   choice.chosen_value  # => "abc"
    # @author Sylvain Daubert
    class Choice < Base

      # Chosen type
      # @return [Integer] index of type in choice value
      attr_accessor :chosen

      # Set chosen value.
      # @note {#chosen} MUST be set before calling this method
      # @param [Object] value
      # @return [Object] value
      # @raise [ChoiceError] {#chosen} not set
      def set_chosen_value(value)
        check_chosen
        @value[@chosen].value = value
      end

      # Get chosen value
      # @note {#chosen} MUST be set before calling this method
      # @return [Object] value
      # @raise [ChoiceError] {#chosen} not set
      def chosen_value
        check_chosen
        @value[@chosen].value
      end

      # @note {#chosen} MUST be set before calling this method
      # @return [String] DER-formated string
      # @raise [ChoiceError] {#chosen} not set
      def to_der
        check_chosen
        @value[@chosen].to_der
      end

      # Parse a DER string. This method updates object by setting {#chosen} and
      # chosen value.
      # @param [String] der DER string
      # @param [Boolean] ber if +true+, accept BER encoding
      # @return [Integer] total number of parsed bytes
      # @raise [ASN1Error] error on parsing
      def parse!(der, ber: false)
        parsed = false
        @value.each_with_index do |element, i|
          begin
            @chosen = i
            nb_bytes = element.parse!(der)
            parsed = true
            break nb_bytes
          rescue ASN1Error
            @chosen = nil
            next
          end
        end
        raise ASN1Error, "CHOICE #@name: no type matching #{der.inspect}" unless parsed
      end

      private

      def check_chosen
        raise ChoiceError if @chosen.nil?
      end
    end
  end
end

      