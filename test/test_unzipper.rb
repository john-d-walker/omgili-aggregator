# test_unzipper.rb

require 'minitest/autorun'
require_relative '../lib/unzipper.rb'

class TestUnzipper < Minitest::Test
  attr_reader :unzipper, :zip_contents_test, :zip_path_test, :updated, :save_path,
    :unzipped_paths

  def setup
    @unzipper = Unzipper.new
    @unzipper.add_observer(self)
    @zip_contents_test = ["e5ca1c48d6cc9a75ea4d4c40c1a0bd48.xml",
                          "5ec79692aa762e6e8375f497b63050df.xml",
                          "3750a18acfdf7fbca340ad3803782a49.xml",
                          "4e6c61da85a2a278cea51426e74dad5c.xml",
                          "c9ade4fc05b652a2d9266e789432edb4.xml",
                          "3731fe8069c2f8d4666ac25b0035919f.xml",
                          "b0cfe5250e8e7a334c4f2a7be9d6e560.xml",
                          "13a8dc01bc279e28a4005ee2ba9d3499.xml",
                          "fe9a71b170754b0e24e8dd66cf6d3d36.xml",
                          "6c2d191d5bbc2b678aac8237ffda4801.xml"]
    @zip_path_test = "test/files/1488148424743.zip"
    @updated = false
    @save_path = "test/files/xml/"
  end

  def update(paths)
    puts 'Receiving update.'
#    puts paths
    @unzipped_paths = paths
    @updated = true
  end

  def test_that_unzipped_contents_are_correct
    @unzipper.unzip(@zip_path_test, @save_path)
    @zip_contents_test.each do |item|
      assert_equal true, @unzipped_paths.include?(@save_path + item)
    end
    # reset
    @unzipped_paths.each do |xml_file|
      File.delete(xml_file)
    end
  end
end

