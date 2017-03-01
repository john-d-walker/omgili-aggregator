# test_download_manager.rb

require 'minitest/autorun'
require_relative '../lib/download_manager.rb'

# Test cases for the DownloadManager class.
class TestDownloadManager < Minitest::Test
  attr_reader :download_manager, :updated, :download_link, :save_path

  def setup
    @download_manager = DownloadManager.new
    @download_manager.add_observer(self)
    @updated = false
    # This link may expire in the future.
    @download_link =
      'http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/1488148424743.zip'
    @save_path = 'test/files/'
  end

  def update(download_path)
    puts 'Receiving update.'
    puts download_path
    @updated = true
  end

  def test_that_file_is_downloaded
    @download_manager.download(@save_path, [@download_link])
    assert_equal true, File.exist?(@save_path + File.basename(@download_link))
  end

  def test_that_observer_was_notified
    @download_manager.download(@save_path, [@download_link])
    assert_equal true, @updated
    # reset
    @updated = false
  end
end
