require_relative '../spec_helper'

module RASN1::Types

  describe OctetString do
    describe '.type' do
      it 'gets ASN.1 type' do
        expect(OctetString.type).to eq('OCTET STRING')
      end
    end

    describe '#initialize' do
      it 'creates a OctetString with default values' do
        os = OctetString.new(:os)
        expect(os).to be_primitive
        expect(os).to_not be_optional
        expect(os.asn1_class).to eq(:universal)
        expect(os.default).to eq(nil)
      end
    end
    
    describe '#to_der' do
      it 'generates a DER string' do
        os = OctetString.new(:os)
        os.value = 'NOP'
        expect(os.to_der).to eq("\x04\x03NOP".force_encoding('BINARY'))
      end

      it 'generates a DER string according to ASN.1 class' do
        os = OctetString.new(:os, class: :context)
        os.value = 'a'
        expect(os.to_der).to eq("\x84\x01a".force_encoding('BINARY'))
      end

      it 'generates a DER string according to default' do
        os = OctetString.new(:os, default: 'NOP', octet_length: 22)
        os.value = 'NOP'
        expect(os.to_der).to eq('')
        os.value = 'N'
        expect(os.to_der).to eq("\x04\x01N".force_encoding('BINARY'))
      end

      it 'generates a DER string according to optional' do
        os = OctetString.new(:os, optional: true)
        os.value = nil
        expect(os.to_der).to eq('')
        os.value = 'abc'
        expect(os.to_der).to eq("\x04\x03abc".force_encoding('BINARY'))
      end
    end

    describe '#parse!' do
      let(:os) { OctetString.new(:os) }

      it 'parses a DER OCTET STRING' do
        os.parse!("\x04\x02\x01\x02".force_encoding('BINARY'))
        expect(os.value).to eq("\x01\x02".force_encoding('BINARY'))
      end
    end
  end
end
