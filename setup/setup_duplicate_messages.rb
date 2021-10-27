require 'yaml'
require_relative '../lib/kafka_producer.rb'

pusher = KafkaProducer.new('customers')
customers = YAML.load(File.read('../test_cases/customers.yaml'))

puts "Unique customer number: #{customers.size}"
customers.map do |customer|
  7.times { pusher.push_customer customer }
end
