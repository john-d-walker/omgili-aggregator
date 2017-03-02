# test_download_manager.rb

require 'minitest/autorun'
require_relative '../lib/download_manager.rb'
require_relative '../lib/scraper.rb'

# Test cases for the DownloadManager class.
class TestDownloadManager < Minitest::Test
  attr_reader :download_manager, :updated, :download_link, :save_path

  def setup
    @download_manager = DownloadManager.new
    @download_manager.add_observer(self)
    @updated = false
    # This link may expire in the future.
    @zip_data = ZipData.new(
      'http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/1488148424742.zip',
      10.0
    )
    @save_path = 'test/files/'
  end

  def update(_save_path, _item)
    @updated = true
  end

  def test_that_file_is_downloaded
    @download_manager.download(@save_path, [@zip_data])
    assert_equal true, File.exist?(@save_path + File.basename(@zip_data.link))
  end

  def test_that_observer_was_notified
    @download_manager.download(@save_path, [@zip_data])
    assert_equal true, @updated
    # reset
    @updated = false
  end
end
