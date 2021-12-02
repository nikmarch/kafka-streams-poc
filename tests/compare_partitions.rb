require 'yaml'
require 'test/unit'


class ComparePartitionsTest < Test::Unit::TestCase
  def setup
    input = YAML.load(File.read('./tests/input_partitions.yaml'))
    output = YAML.load(File.read('./tests/output_partitions.yaml'))
    @actual = Hash.new
    @expected = Hash.new

    input.each { |v| @expected[v.fetch('key')] = v.fetch('partition')}
    output.each { |v| @actual[v.fetch('key')] = v.fetch('partition')}
  end

  def test_1
    @expected.keys.each do |key|
      assert_equal @expected.fetch(key), @actual.fetch(key), "Not match for key #{key}"
    end
  end
end
