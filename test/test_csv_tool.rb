# test_csv_tool.rb

require 'minitest/autorun'
require_relative '../lib/csv_tool.rb'

class TestCSVTool < Minitest::Test
  attr_reader :csv_tool, :read_contents_test_array

  def setup
    @csv_tool = CSVTool.new
    @read_contents_test_array = ["1487807963738.zip",
                                 "1487808083762.zip",
                                 "1487808230988.zip",
                                 "1487808401176.zip",
                                 "1487808621686.zip",
                                 "1487808834319.zip",
                                 "1487808843365.zip",
                                 "1487808855456.zip",
                                 "1487809006694.zip",
                                 "1487809228664.zip",
                                 "1487809380526.zip"]

  end

  def test_that_read_contents_are_correct
    @csv_tool.read("test/files/test.csv").each do |item|
      assert_equal true, @read_contents_test_array.include?(item)
    end
  end

  def test_read_returns_nil_when_path_invalid
    assert_equal nil, @csv_tool.read("test/files/test.exe")
  end

  def test_write_returns_nil_when_path_is_nil
    assert_equal nil, @csv_tool.write(nil, @read_contents_test_array)
  end

  def test_write_returns_nil_when_array_is_nil
    assert_equal nil, @csv_tool.write("test/files/write_test.csv", nil)
  end

  def test_write_file_contents_are_correct
    write_path = "test/files/write_test.csv"
    @csv_tool.write(write_path, @read_contents_test_array)
    @csv_tool.read(write_path).each do |item|
      assert_equal true, @read_contents_test_array.include?(item)
    end
    File.delete(write_path)
  end
end

