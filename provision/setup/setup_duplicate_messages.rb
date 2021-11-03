require 'yaml'
require_relative '../lib/kafka_producer.rb'

pusher = KafkaProducer.new('customers')
customers = YAML.load(File.read('./test_cases/customers.yaml'))
dup_nums = 7

puts "Unique customer number: #{customers.size}"
customers.map do |customer|
  dup_nums.times { pusher.push_customer customer }
  puts "customer: #{customer.fetch('uuid')} pushed #{dup_nums}"
end
