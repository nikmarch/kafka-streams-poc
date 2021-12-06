require 'jbundler'
require 'java'

class Config
  java_import 'java.util.Properties'
  java_import 'org.apache.kafka.streams.StreamsConfig'
  java_import 'org.apache.kafka.common.serialization.Serdes'

  def streams_configuration
    props = Properties.new
    props.put(StreamsConfig::APPLICATION_ID_CONFIG, ENV['APPLICATION_ID_CONFIG'])
    props.put(StreamsConfig::BOOTSTRAP_SERVERS_CONFIG, ENV['BOOTSTRAP_SERVERS_CONFIG'])
    props.put(StreamsConfig::CLIENT_ID_CONFIG, ENV['CLIENT_ID_CONFIG'])
    props.put(StreamsConfig::DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass())
    props.put(StreamsConfig::DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass())
    props
  end

  def window_size_duration
    (ENV['WINDOW_SIZE_DURATION_IN_SECONDS'] || 20).to_i
  end

  def store_name
    ENV['STORE_NAME']
  end

  def input_topic
    ENV['INPUT_TOPIC_NAME']
  end

  def output_topic
    ENV['OUTPUT_TOPIC_NAME']
  end
end
