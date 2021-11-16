require 'jbundler'
require 'tmpdir'
require 'pry'
require 'fileutils'
require 'java'

class DeduplicationTransformer
  java_import 'org.apache.kafka.streams.KafkaStreams'
  java_import 'java.util.Properties'
  java_import 'java.time.Duration'
  java_import 'org.apache.kafka.common.serialization.Serdes'
  java_import 'org.apache.kafka.common.serialization.StringDeserializer'
  java_import 'org.apache.kafka.common.serialization.StringSerializer'
  java_import 'org.apache.kafka.streams.KeyValue'
  java_import 'org.apache.kafka.streams.StreamsBuilder'
  java_import 'org.apache.kafka.streams.StreamsConfig'
  java_import 'org.apache.kafka.streams.kstream.KStream'
  java_import 'org.apache.kafka.streams.kstream.KeyValueMapper'
  java_import 'org.apache.kafka.streams.kstream.Transformer'
  java_import 'org.apache.kafka.streams.kstream.TransformerSupplier'
  java_import 'org.apache.kafka.streams.processor.ProcessorContext'
  java_import 'org.apache.kafka.streams.state.StoreBuilder'
  java_import 'org.apache.kafka.streams.state.Stores'
  java_import 'org.apache.kafka.streams.state.WindowStore'
  java_import 'org.apache.kafka.streams.state.WindowStoreIterator'
  java_import 'org.apache.commons.codec.digest.DigestUtils'

  attr_accessor :streams

  def self.store_name
    'event_id_store'
  end

  class MyTransformer
    include Transformer

    def initialize(maintain_duration_per_message_in_ms)
      @left_duration_in_ms = maintain_duration_per_message_in_ms / 2
      @right_duration_in_ms = maintain_duration_per_message_in_ms - @left_duration_in_ms
    end

    def init(context)
      @context = context
      @store = context.getStateStore(DeduplicationTransformer::store_name)
    end

    def transform(key, value)
      hash_key = generate_hash_key(value)

      if is_duplicate(hash_key)
        output = nil
        update_timestamp_of_existing_message_to_prevent_expiry(hash_key, @context.timestamp)
      else
        output = KeyValue.new(key, value)
        remember_new_message(hash_key, @context.timestamp)
      end
      output
    end

    def generate_hash_key(value)
      DigestUtils.md5Hex(value)
    end

    def is_duplicate(key)
      event_time = @context.timestamp
      time_iterator = @store.fetch(key, event_time - @left_duration_in_ms, event_time + @right_duration_in_ms)
      is_duplicate = time_iterator.has_next
      time_iterator.close
      is_duplicate
    end

    def update_timestamp_of_existing_message_to_prevent_expiry(key, new_timestamp)
      @store.put(key, new_timestamp, new_timestamp)
    end

    def remember_new_message(key, timestamp)
      @store.put(key, timestamp, timestamp)
    end

    def close

    end
  end


  class MyTransformerSupplier
    include TransformerSupplier

    def initialize(maintain_duration_per_message_in_ms)
      @maintain_duration_per_message_in_ms = maintain_duration_per_message_in_ms
    end

    def get
      MyTransformer.new(@maintain_duration_per_message_in_ms)
    end
  end
  def start
    puts "Application started"

    props = Properties.new
    props.put(StreamsConfig::APPLICATION_ID_CONFIG, 'deduplicated_customers_application_id')
    props.put(StreamsConfig::BOOTSTRAP_SERVERS_CONFIG, 'broker:9092,broker:29092')
    props.put(StreamsConfig::CLIENT_ID_CONFIG, 'deduplicated_customers_client_id')
    props.put(StreamsConfig::DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass())
    props.put(StreamsConfig::DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass())

    create_streams(props)

    streams.start()

    # at_exit do
    #   puts "\nClosing Streams"
    #   streams.close()
    #   # puts "Deleting temp directory: #{temp_directory}"
    #   # FileUtils.remove_dir(temp_directory)
    # end
  end

  def create_streams(streams_configuration)
    builder = StreamsBuilder.new
    windowSize = Duration.ofSeconds(20);

    retentionPeriod = windowSize
    dedupStoreBuilder = Stores.windowStoreBuilder(
      Stores.persistentWindowStore(DeduplicationTransformer::store_name,
                                   retentionPeriod,
                                   windowSize,
                                   false
                                  ),
                                  Serdes.String(),
                                  Serdes.Long())

    builder.addStateStore(dedupStoreBuilder)

    # binding.pry
    builder.stream('customers')
      .transform(MyTransformerSupplier.new(windowSize.toMillis), DeduplicationTransformer::store_name)
      .to('deduplicated_customers')

    topology = builder.build()
    puts topology.describe()

    self.streams = KafkaStreams.new(topology, streams_configuration)

  rescue => e
    puts e
  end
end

DeduplicationTransformer.new.start
