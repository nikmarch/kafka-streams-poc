require 'kafka'
require 'json'

class KafkaProducer
  def initialize(topic)
    @topic = topic
    @kafka = Kafka.new "broker:9092", client_id: "console_test"
  end

  def push_customer(customer, attempt = 1)
    key = customer.fetch('uuid')
    payload = JSON.generate customer
    @kafka.deliver_message payload, topic: @topic, key: key
    # puts "#{key} published"
  rescue => e # TODO replace by implicit Kafka exception
    if attempt > 5
      raise e
    end
    puts "Kafka Connection error attempt: #{attempt}"
    sleep 5
    push_customer customer, attempt + 1
  end
end
