# test_download_manager.rb

require 'minitest/autorun'
require_relative '../lib/download_manager.rb'

class TestDownloadManager < Minitest::Test
  attr_reader :download_manager, :updated, :download_link, :save_path

  def setup
    @download_manager = DownloadManager.new
    @download_manager.add_observer(self)
    @updated = false
    @download_link = "http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/1487883571566.zip"
    @save_path = "test/files/"
  end

  def update(download_path)
    puts 'Receiving update.'
    @updated = true
  end

  def test_that_observer_was_added
    assert_equal 1, @download_manager.count_observers
  end

  def test_that_file_is_downloaded
    @download_manager.download(@save_path, [@download_link])
    assert_equal true, File.exists?(@save_path + "1487883571566.zip")
  end

  def test_that_observer_was_notified
    @download_manager.download(@save_path, [@download_link])
    assert_equal true, @updated
    # reset 
    @updated = false
  end 
end

