require 'tmpdir'
require 'fileutils'
require 'java'
require 'jbundler'
require '../serde/avro_serde'

class ShipmentsInteractiveQueries
  java_import 'java.util.Properties'
  java_import 'org.apache.kafka.common.serialization.Serdes'
  java_import 'org.apache.kafka.streams.Consumed'
  java_import 'org.apache.kafka.streams.KafkaStreams'
  java_import 'org.apache.kafka.streams.StreamsBuilder'
  java_import 'org.apache.kafka.streams.StreamsConfig'
  java_import 'org.apache.kafka.streams.Topology'
  java_import 'org.apache.kafka.streams.kstream.Materialized'
  java_import 'org.apache.kafka.streams.kstream.Serialized'
  java_import 'org.apache.kafka.streams.kstream.TimeWindows'

  attr_accessor :streams, :shipments_table

  def start(port)
    temp_directory = Dir.mktmpdir('example')
    puts "Temp directory: #{temp_directory}"

    props = Properties.new
    props.put(StreamsConfig::APPLICATION_ID_CONFIG, 'shipments-interactive-queries-example')
    props.put(StreamsConfig::CLIENT_ID_CONFIG, 'shipments-interactive-queries-example-client')
    props.put(StreamsConfig::BOOTSTRAP_SERVERS_CONFIG, 'localhost:9092')
    props.put(StreamsConfig::DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass())
    props.put(StreamsConfig::DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass())
    if port
      props.put(StreamsConfig::APPLICATION_SERVER_CONFIG, "localhost:#{port}")
    end
    props.put(StreamsConfig::STATE_DIR_CONFIG, temp_directory)

    puts "Config Properties:"
    pp props

    create_streams(props)

    at_exit do
      puts "\nClosing Streams"
      streams.close()
      puts "Deleting temp directory: #{temp_directory}"
      FileUtils.remove_dir(temp_directory)
    end

    streams.clean_up()
    streams.start()
  end

  def create_streams(streams_configuration)
    builder = StreamsBuilder.new

    avro_serde = AvroSerde.new
    avro_serde.configure({
      'schema_name' => 'shipment',
      'namespace' => 'com.dollarshaveclub.fulfillment'
    }, false)

    self.shipments_table = builder.table('example-shipments', Consumed.with(Serdes.String(), avro_serde), Materialized.as('shipments-by-guid'))

    topology = builder.build()
    puts topology.describe()

    self.streams = KafkaStreams.new(topology, streams_configuration)
  end
end
