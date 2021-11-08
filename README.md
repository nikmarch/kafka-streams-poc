# Kafka Streams: Deduplicating events
- Sample class: https://github.com/confluentinc/kafka-streams-examples/blob/master/src/test/java/io/confluent/examples/streams/EventDeduplicationLambdaIntegrationTest.java
- Classes docs: https://kafka.apache.org/25/javadoc/org/apache/kafka/streams/kstream/KStream.html#transform-org.apache.kafka.streams.kstream.TransformerSupplier-org.apache.kafka.streams.kstream.Named-java.lang.String...-

# To run:
```
docker-compose up -d
./scripts/push_customers.sh
./scripts/consume_deduplicated_customers.sh
cd app
bundle exec ruby stream.rb
```
