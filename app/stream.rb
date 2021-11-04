require 'tmpdir'
require 'pry'
require 'fileutils'
require 'java'
require 'jbundler'

class DeduplicationTransformer
  # java_import 'org.apache.kafka.common.serialization.Serdes'
  java_import 'org.apache.kafka.streams.KafkaStreams'
  # java_import 'org.apache.kafka.streams.StreamsBuilder'
  # java_import 'org.apache.kafka.streams.StreamsConfig'
  java_import 'java.util.Properties'
  java_import 'org.apache.kafka.common.serialization.Serdes'
  java_import 'org.apache.kafka.common.serialization.StringDeserializer'
  java_import 'org.apache.kafka.common.serialization.StringSerializer'
  java_import 'org.apache.kafka.streams.KeyValue'
  java_import 'org.apache.kafka.streams.StreamsBuilder'
  java_import 'org.apache.kafka.streams.StreamsConfig'
  java_import 'org.apache.kafka.streams.kstream.KStream'
  java_import 'org.apache.kafka.streams.kstream.KeyValueMapper'
  java_import 'org.apache.kafka.streams.kstream.Transformer'
  java_import 'org.apache.kafka.streams.processor.ProcessorContext'
  java_import 'org.apache.kafka.streams.state.StoreBuilder'
  java_import 'org.apache.kafka.streams.state.Stores'
  java_import 'org.apache.kafka.streams.state.WindowStore'
  java_import 'org.apache.kafka.streams.state.WindowStoreIterator'

  attr_accessor :streams

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

    # at_exit do
    #   puts "\nClosing Streams"
    #   streams.close()
    #   # puts "Deleting temp directory: #{temp_directory}"
    #   # FileUtils.remove_dir(temp_directory)
    # end

    streams.start()
  end

  def create_streams(streams_configuration)
    builder = StreamsBuilder.new

    # self.shipments_table = builder.table('example-shipments', Consumed.with(Serdes.String(), avro_serde), Materialized.as('shipments-by-guid'))

    # topology = builder.build()
    # puts topology.describe()

    builder.stream('customers')
      .map_values do |k,v|
        puts "k: #{k}"
        puts "v: #{v}"
        v
      end
      .to('deduplicated_customers')
      #
    # binding.pry
    self.streams = KafkaStreams.new(builder.build, streams_configuration)
    puts "Streams started"
    rescue => e
    puts e
  end
end

DeduplicationTransformer.new.start
