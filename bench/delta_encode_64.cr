require "../src/delta_encoding_64"

module Delta64Encode
  module Global
    @@summary_packed = 0_u64

    def self.summary_packed
      @@summary_packed
    end

    def self.summary_packed=(value)
      @@summary_packed = value
    end
  end

  def self.test_encode(name, count, data)
    t = Time.now
    print name
    res = 0
    count.times do |i|
      encoder = DeltaEncoding64::Encoder.new
      data.each do |integer|
        encoder.write_integer(integer)
      end
      encoder.flush
      res += encoder.bytes.size
    end
    puts " = #{res / 1024 / 1024} Mb original size: #{count*data.size * 4 / 1024 / 1024}, #{Time.now - t}"
    Global.summary_packed += res
  end

  t = Time.now

  puts self
  test_encode("increasing integers", 100_000, Slice(Int64).new(1000) { |n| rand(1..(n + 1)).to_i64 })
  test_encode("small integers", 100_000, Slice(Int64).new(1000) { |n| 2_i64 })
  test_encode("large integers", 100_000, Slice(Int64).new(1000) { |n| 1_i64 << 31 })

  test_encode("random integers", 100_000, Slice(Int64).new(1000) { |n| rand(1..12345).to_i64 })
  test_encode("timestamps", 100_000, Slice(Int64).new(1000) { |n| t.epoch.to_i64 })

  puts "Summary packed size: #{Global.summary_packed / 1024 / 1024} Mb"
  puts "Summary time: #{Time.now - t}"
end
