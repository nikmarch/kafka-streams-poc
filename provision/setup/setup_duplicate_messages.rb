require 'yaml'
require_relative '../lib/kafka_producer.rb'

pusher = KafkaProducer.new('customers')
customers = YAML.load(File.read('./test_cases/customers.yaml'))
dup_nums = 7

puts "Unique customer number: #{customers.size}"
dup_nums.times do |num|
  customers.map do |customer|
    pusher.push_customer customer
    puts "customer: #{customer.fetch('uuid')} pushed #{num + 1}"
  end
end
