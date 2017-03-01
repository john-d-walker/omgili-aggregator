# download_manager.rb

require 'observer'
require 'net/http'

# Downloads items in a list one at a time.
class DownloadManager
  include Observable

  def download(save_path, download_list)
    download_list.each do |item|
      filename = File.basename(item.link)

      File.write(save_path + filename, Net::HTTP.get(URI.parse(item.link)))

      changed
      notify_observers(save_path + filename, item)
    end
  end
end
