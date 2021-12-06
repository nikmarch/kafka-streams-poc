require 'jbundler'
require 'java'

class Config
  java_import 'java.util.Properties'
  java_import 'org.apache.kafka.streams.StreamsConfig'
  java_import 'org.apache.kafka.common.serialization.Serdes'

  def streams_configuration
    props = Properties.new
    props.put(StreamsConfig::APPLICATION_ID_CONFIG, 'deduplicated_customers_application_id')
    props.put(StreamsConfig::BOOTSTRAP_SERVERS_CONFIG, 'broker:9092')
    # props.put(StreamsConfig::BOOTSTRAP_SERVERS_CONFIG, 'broker:9092,broker:29092')
    props.put(StreamsConfig::CLIENT_ID_CONFIG, 'deduplicated_customers_client_id')
    props.put(StreamsConfig::DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass())
    props.put(StreamsConfig::DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass())
    props
  end

  def window_size_duration
    20 # seconds
  end

  def store_name
    'deduplication_store'
  end

  def input_topic
    'customers'
  end

  def output_topic
    'deduplicated_customers'
  end
end
