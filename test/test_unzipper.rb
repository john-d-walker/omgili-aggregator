# test_unzipper.rb

require 'minitest/autorun'
require_relative '../lib/unzipper.rb'

class TestUnzipper < Minitest::Test
  attr_reader :unzipper, :zip_contents_test, :zip_path_test, :updated, :save_path,
    :unzipped_contents, :test_xml_path

  def setup
    @unzipper = Unzipper.new
    @unzipper.add_observer(self)
    @zip_contents_test = "e5ca1c48d6cc9a75ea4d4c40c1a0bd48.xml"
    @zip_path_test = "test/files/1488148424743.zip"
    @updated = false
    @save_path = "test/files/xml/"
    @test_xml_path = "test/files/test.xml"
  end

  def update(unzipped_contents)
    puts 'Receiving update.'
    @unzipped_contents = unzipped_contents
    @updated = true
  end

  def test_that_unzipped_contents_are_correct
    @unzipper.unzip(@zip_path_test, @save_path)
    assert_equal File.open(@test_xml_path).read, @unzipped_contents[0]

    # reset
    File.delete("#{@save_path}*.xml")
  end
end

