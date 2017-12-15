require_relative '../spec_helper'

module RASN1
  module Types

    class SimpleModel < Model
      sequence :seq,
               content: [boolean(:bool), integer(:int)]
    end

    describe SequenceOf do
      before(:each) do
        @seq = Sequence.new
        @bool = Boolean.new(default: true)
        @int = Integer.new
        @os = OctetString.new
        @seq.value = [@bool, @int, @os]
        @seqof = SequenceOf.new(@seq)

        @composed_der = binary("\x30\x1a" +
                               "\x30\x09\x02\x01\x0c\x04\x04abcd" + 
                               "\x30\x0d\x01\x01\x00\x02\x03\x00\xff\xfe\x04\x03nop")
        @integer_der = binary("\x30\x18" +
                              (0..7).map { |v| Integer.new(v).to_der }.join)
        end
        
      describe '.type' do
        it 'gets ASN.1 type' do
          expect(SequenceOf.type).to eq('SEQUENCE OF')
        end
      end

      describe '#initialize' do
        it 'creates an SequenceOf with default values' do
          seqof = SequenceOf.new(Types::Integer)
          expect(seqof).to be_constructed
          expect(seqof).to_not be_optional
          expect(seqof.asn1_class).to eq(:universal)
          expect(seqof.default).to eq(nil)
          expect(seqof.of_type).to eq(Types::Integer)
        end

        it 'accepts a Model as type' do
          expect { SequenceOf.new(SimpleModel) }.to_not raise_error
        end

        it 'raises if no type is given' do
          expect { SequenceOf.new }.to raise_error(ArgumentError)
        end
      end

      describe '#to_der' do
        it 'generates a DER string for a primitive type' do
          seqof = SequenceOf.new(Integer)
          seqof << (0..7).to_a
          expect(seqof.to_der).to eq(@integer_der)
        end

        it 'generates a DER string for a composed type' do
          @seqof << [true, 12, 'abcd']
          @seqof << [false, 65534, 'nop']
          expect(@seqof.to_der).to eq(@composed_der)
          # expect #to_der does not alterate type (here @seq, so @bool and @int too)
          expect(@bool.value).to_not be(false)
          expect(@int.value).to be(nil)
        end

        it 'generates a DER string for a model type' do
          seqof = SequenceOf.new(SimpleModel)
          seqof << { bool: true, int: 12 }
          seqof << { bool: false, int: 65535 }
          expected_der = binary("\x30\x12" \
                                "\x30\x06\x01\x01\xff\x02\x01\x0c" \
                                "\x30\x08\x01\x01\x00\x02\x03\x00\xff\xff")
          expect(seqof.to_der).to eq(expected_der)
        end
      end

      describe '#parse!' do
        it 'parses DER string for a primitive type' do
          seqof = SequenceOf.new(Integer)
          seqof.parse!(@integer_der)
          expect(seqof.value).to eq((0..7).to_a.map { |v| Integer.new(v) })
        end

        it 'parses DER string for a composed type' do
          @seqof.parse!(@composed_der)
          golden = []
          golden << Sequence.new([Boolean.new(default: true),
                                  Integer.new(12),
                                  OctetString.new('abcd')])
          golden << Sequence.new([Boolean.new(false),
                                  Integer.new(65534),
                                  OctetString.new('nop')])
          expect(@seqof.value).to eq(golden)
        end

        it 'parses DER string for a model type' do
          seqof = SequenceOf.new(SimpleModel)
          der = binary("\x30\x11" \
                       "\x30\x06\x01\x01\xff\x02\x01\x7f" \
                       "\x30\x07\x01\x01\x00\x02\x02\x7f\xff")
          seqof.parse!(der)
          golden = []
          golden << SimpleModel.new(bool: true, int: 127)
          golden << SimpleModel.new(bool: false, int: 32767)
          expect(seqof.value).to eq(golden)
        end

        it 'parses DER string with explicit option' do
          seqof = SequenceOf.new(Integer, explicit: 3)
          seqof.parse!(binary("\xa3\x1a" + @integer_der))
          expect(seqof.value).to eq((0..7).to_a.map { |v| Integer.new(v)})
        end
      end
    end
  end
end
