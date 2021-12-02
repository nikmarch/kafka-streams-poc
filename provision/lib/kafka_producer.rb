require 'kafka'
require 'json'

class KafkaProducer
  def initialize(topic)
    @topic = topic
    @kafka = Kafka.new("broker:9092", client_id: "console_test")
    @kafka.create_topic(@topic, num_partitions: 8) unless @kafka.topics.include? @topic
    if @kafka.topics.include? "deduplicated_#{@topic}"
      @kafka.delete_topic("deduplicated_#{@topic}")
      @kafka.create_topic("deduplicated_#{@topic}", num_partitions: 8)
    else
      @kafka.create_topic("deduplicated_#{@topic}", num_partitions: 8)
    end
  end

  def push_customer(customer, attempt = 1)
    key = customer.fetch('key').to_s
    partition = customer.fetch('partition')
    payload = JSON.generate customer.fetch('message')
    @kafka.deliver_message payload, topic: @topic, key: key, partition: partition
  rescue => e # TODO replace by implicit Kafka exception
    if attempt > 5
      raise e
    end
    puts "Kafka Connection error attempt: #{attempt}"
    sleep 5
    push_customer customer, attempt + 1
  end
end
