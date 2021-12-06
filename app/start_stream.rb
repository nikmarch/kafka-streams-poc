require 'jbundler'
require 'java'
require_relative './crc32_partitioner'
require_relative './deduplication_transformer_supplier'
require_relative './config'

class DeduplicationStream
  java_import 'org.apache.kafka.streams.KafkaStreams'
  java_import 'java.time.Duration'
  java_import 'org.apache.kafka.common.serialization.Serdes'
  java_import 'org.apache.kafka.common.serialization.StringDeserializer'
  java_import 'org.apache.kafka.common.serialization.StringSerializer'
  java_import 'org.apache.kafka.streams.StreamsBuilder'
  java_import 'org.apache.kafka.streams.kstream.KStream'
  java_import 'org.apache.kafka.streams.kstream.KeyValueMapper'
  java_import 'org.apache.kafka.streams.kstream.Produced'
  java_import 'org.apache.kafka.streams.processor.ProcessorContext'
  java_import 'org.apache.kafka.streams.state.StoreBuilder'
  java_import 'org.apache.kafka.streams.state.Stores'
  java_import 'org.apache.kafka.streams.state.WindowStore'
  java_import 'org.apache.kafka.streams.state.WindowStoreIterator'

  def start
    puts "Application started"

    config = Config.new
    streams = create_streams(config)
    streams.start()

    # at_exit do
    #   puts "\nClosing Streams"
    #   streams.close()
    #   # puts "Deleting temp directory: #{temp_directory}"
    #   # FileUtils.remove_dir(temp_directory)
    # end
  end

  def create_streams(config)
    builder = StreamsBuilder.new
    windowSize = Duration.ofSeconds(config.window_size_duration);

    retentionPeriod = windowSize
    dedupStoreBuilder = Stores.windowStoreBuilder(
      Stores.persistentWindowStore(
        config.store_name,
        retentionPeriod,
        windowSize,
        false
      ),
      Serdes.String(),
      Serdes.Long())

    produced = Produced.with(
      Serdes.String(),
      Serdes.String(),
      CRC32Partitioner.new
    )

    builder.addStateStore(dedupStoreBuilder)
    transformer_supplier = DeduplicationTransformerSupplier.new(windowSize.toMillis, config.store_name)

    builder.stream(config.input_topic)
      .transform(transformer_supplier, config.store_name)
      .to(config.output_topic, produced)

    topology = builder.build()
    puts topology.describe()

    KafkaStreams.new(topology, config.streams_configuration)
  rescue => e
    puts e
  end
end

DeduplicationStream.new.start
