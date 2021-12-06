require 'java'
require 'jbundler'

class DeduplicationTransformer
  java_import 'org.apache.commons.codec.digest.DigestUtils'
  java_import 'org.apache.kafka.streams.KeyValue'
  java_import 'org.apache.kafka.streams.kstream.Transformer'

  include Transformer

  def initialize(maintain_duration_per_message_in_ms, store_name)
    @left_duration_in_ms = maintain_duration_per_message_in_ms / 2
    @right_duration_in_ms = maintain_duration_per_message_in_ms - @left_duration_in_ms
    @store_name = store_name
  end

  def init(context)
    @context = context
    @store = context.getStateStore(@store_name)
  end

  def transform(key, value)
    hash_key = generate_hash_key(value)

    if is_duplicate(hash_key)
      output = nil
      update_timestamp_of_existing_message_to_prevent_expiry(hash_key, @context.timestamp)
    else
      output = KeyValue.new(key, value)
      remember_new_message(hash_key, @context.timestamp)
    end
    output
  end

  def generate_hash_key(value)
    DigestUtils.md5Hex(value)
  end

  def is_duplicate(key)
    event_time = @context.timestamp
    time_iterator = @store.fetch(key, event_time - @left_duration_in_ms, event_time + @right_duration_in_ms)
    is_duplicate = time_iterator.has_next
    time_iterator.close
    is_duplicate
  end

  def update_timestamp_of_existing_message_to_prevent_expiry(key, new_timestamp)
    @store.put(key, new_timestamp, new_timestamp)
  end

  def remember_new_message(key, timestamp)
    @store.put(key, timestamp, timestamp)
  end

  def close

  end
end

