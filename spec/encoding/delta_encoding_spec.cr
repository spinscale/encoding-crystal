require "../spec_helper"

describe DeltaEncoding do
  it "encodes and decodes a block" do
    encoder = DeltaEncoding::Encoder.new
    4.times do |i|
      encoder.write_integer(i)
    end
    encoder.flush

    io = IO::Memory.new
    encoder.to_io(io)
    io.rewind
    decoder = DeltaEncoding::Decoder.new(io)

    decoder.values.to_a.should eq [0, 1, 2, 3]
  end

  it "encodes and decodes 1 value" do
    encoder = DeltaEncoding::Encoder.new
    encoder.write_integer(1)
    encoder.flush

    io = IO::Memory.new
    encoder.to_io(io)
    io.rewind
    decoder = DeltaEncoding::Decoder.new(io)

    decoder.values.to_a.should eq [1]
  end

  it "it consumes all bytes when reading" do
    encoder = DeltaEncoding::Encoder.new
    129.times do |i|
      encoder.write_integer(rand(1466666000))
    end
    encoder.flush

    io = IO::Memory.new
    encoder.to_io(io)
    io.rewind

    decoder = DeltaEncoding::Decoder.new(io)
    decoder.values.size.should eq 129

    io.pos.should eq io.size
  end

  it "with a negative delta" do
    wide_range = [Int32::MAX, Int32::MIN, 0]

    encoder = DeltaEncoding::Encoder.new
    wide_range.each do |integer|
      encoder.write_integer(integer)
    end
    encoder.flush

    io = IO::Memory.new
    encoder.to_io(io)
    io.rewind

    decoder = DeltaEncoding::Decoder.new(io)
    decoder.values.should eq wide_range
  end
end
