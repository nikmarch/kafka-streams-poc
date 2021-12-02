require 'yaml'
require_relative '../lib/kafka_producer.rb'

pusher = KafkaProducer.new('customers')
customers = YAML.load(File.read('./test_cases/production_customers.yaml'))

puts "Unique customer number: #{customers.size}"
customers.map do |customer|
  pusher.push_customer customer
  puts "customer: #{customer.fetch('key')} pushed"
end
