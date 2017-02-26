# download_manager.rb

require 'observer'
require 'net/http'

class DownloadManager
  include Observable

  def download(save_path, download_list)
    download_list.each do |item|
      filename = File.basename(item)
      File.write(save_path + filename, Net::HTTP.get(URI.parse(item)))
      changed
      notify_observers(save_path + filename)
    end
  end
end

