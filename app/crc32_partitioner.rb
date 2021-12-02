require 'java'
require 'zlib'

# Turns out ruby-kafka uses a different partition assignment scheme than
# the official Kafka java library. In order to allow kafka-streams state-store
# lookups by key to return the correct instance when consuming a topic produced
# by ruby-kafka, we have to make the same partitioning implementation available
# to Java.

class CRC32Partitioner
  include org.apache.kafka.streams.processor.StreamPartitioner

  def partition(topic, key, value, num_partitions)
    data = key || value

    if data.nil?
      rand(num_partitions).to_java(:int)
    else
      # https://github.com/zendesk/ruby-kafka/blob/master/lib/kafka/partitioner.rb#L31
      (Zlib.crc32(data.to_s) % num_partitions).abs.to_java(:int)
    end
  end
end
