require 'tmpdir'
require 'pry'
require 'fileutils'
require 'java'
require 'jbundler'

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

  attr_accessor :streams

  def self.store_name
    'event_id_store'
  end

  class MyTransformer
    include Transformer

    def init(context)
      puts 'inside MyTransformer'
      @context = context
      @state = context.getStateStore(DeduplicationTransformer::store_name)
    end

    def transform(key, value)
      puts "key: #{key}"
      puts "value: #{value}"
      KeyValue.new(key, value)
    end

    def close

    end
  end


  class MyTransformerSupplier
    include TransformerSupplier

    def get
      puts 'inside MyTransformerSupplier'
      MyTransformer.new
    end
  end
  def start
    # temp_directory = Dir.mktmpdir('example')
    # puts "Temp directory: #{temp_directory}"
    puts "Application started"

    props = Properties.new
    props.put(StreamsConfig::APPLICATION_ID_CONFIG, 'deduplicated_customers_application_id')
    props.put(StreamsConfig::CLIENT_ID_CONFIG, 'deduplicated_customers_client_id')
    props.put(StreamsConfig::BOOTSTRAP_SERVERS_CONFIG, 'localhost:29092')
    props.put(StreamsConfig::DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass())
    props.put(StreamsConfig::DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass())
    # if port
    #   props.put(StreamsConfig::APPLICATION_SERVER_CONFIG, "localhost:#{port}")
    # end
    # props.put(StreamsConfig::STATE_DIR_CONFIG, temp_directory)

    puts "Config Properties:"
    pp props

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
    windowSize = Duration.ofMinutes(10);

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
    # builder.stream('customers')
    # .map_values do |k,v|
    #   puts "k: #{k}"
    #   puts "v: #{v}"
    #   sleep 1
    #   v
    # end
    # .to('deduplicated_customers')
    puts 'before stram'
    builder.stream('customers')
      .transform(MyTransformerSupplier.new, DeduplicationTransformer::store_name)
      .to('deduplicated_customers')
    puts 'after stram'

    topology = builder.build()
    puts topology.describe()

    self.streams = KafkaStreams.new(topology, streams_configuration)

    puts "Streams started"
  rescue => e
    puts e
  end
end

DeduplicationTransformer.new.start
