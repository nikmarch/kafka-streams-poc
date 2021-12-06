require 'jbundler'
require 'java'
require_relative './deduplication_transformer'

class DeduplicationTransformerSupplier
  java_import 'org.apache.kafka.streams.kstream.TransformerSupplier'

  include TransformerSupplier

  def initialize(maintain_duration_per_message_in_ms, store_name)
    @maintain_duration_per_message_in_ms = maintain_duration_per_message_in_ms
    @store_name = store_name
  end

  def get
    DeduplicationTransformer.new(@maintain_duration_per_message_in_ms, @store_name)
  end
end
