# download_manager.rb

require 'observer'
require 'net/http'

class DownloadManager
  include Observable

  def download(save_path, download_list)
    count = 1 
    download_list.each do |item|
      filename = File.basename(item.link)

      File.write(save_path + filename, Net::HTTP.get(URI.parse(item.link)))

      puts "Download count: #{count}/#{download_list.length}" ##############################
      count += 1

      changed
      notify_observers(save_path + filename)
    end
  end
end

