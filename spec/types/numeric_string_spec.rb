# coding: utf-8
require_relative '../spec_helper'

module RASN1::Types

  describe NumericString do
    describe '.type' do
      it 'gets ASN.1 type' do
        expect(NumericString.type).to eq('NumericString')
      end
    end

    describe '#initialize' do
      it 'creates a NumericString with default values' do
        numeric = NumericString.new
        expect(numeric).to be_primitive
        expect(numeric).to_not be_optional
        expect(numeric.asn1_class).to eq(:universal)
        expect(numeric.default).to eq(nil)
      end
    end
    
    describe '#to_der' do
      it 'generates a DER string' do
        numeric = NumericString.new
        numeric.value = '20 12'
        expect(numeric.to_der).to eq(binary("\x12\x0520 12"))
      end

      it 'generates a DER string according to ASN.1 class' do
        numeric = NumericString.new(class: :context)
        numeric.value = '8'
        expect(numeric.to_der).to eq(binary("\x92\x018"))
      end

      it 'generates a DER string according to default' do
        numeric = NumericString.new(default: '123')
        numeric.value = '123'
        expect(numeric.to_der).to eq('')
        numeric.value = '12'
        expect(numeric.to_der).to eq(binary("\x12\x0212"))
      end

      it 'generates a DER string according to optional' do
        numeric = NumericString.new(optional: true)
        numeric.value = nil
        expect(numeric.to_der).to eq('')
        numeric.value = '123'
        expect(numeric.to_der).to eq(binary("\x12\x03123"))
      end

      it 'raises on illegal character' do
        numeric = NumericString.new
        numeric.value = 'a'
        expect {numeric.to_der }.to raise_error(RASN1::ASN1Error, /invalid char.*'a'$/)
      end
    end

    describe '#parse!' do
      let(:numeric) { NumericString.new }

      it 'parses a DER NUMERIC STRING' do
        numeric.parse!(binary("\x12\x0412 3"))
        expect(numeric.value).to eq('12 3')
      end

      it 'raises on illegal character' do
        expect { numeric.parse!(binary("\x12\x0312x")) }.
          to raise_error(RASN1::ASN1Error, /invalid char.*'x'$/)
      end
    end
  end
end
