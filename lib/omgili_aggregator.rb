# omgili_aggregator.rb

require_relative 'scraper'
require_relative 'easy_csv'
require_relative 'download_manager'
require_relative 'unzipper'
require_relative 'redis_pusher'
require_relative 'progress_publisher'
require_relative 'config_parser'

def generate_download_list(csv_data, scrape_data)
  results = []

  scrape_data.each do |item|
    results.push(item) unless csv_data.include?(item)
  end

  results
end

# Returns the sum total of the size of the download_list in MB
def download_list_size(download_list)
  download_list_size_mb = 0.0
  download_list.each do |item|
    download_list_size_mb += item.size
  end

  download_list_size_mb
end

# Used for testing with smaller datasets if you have limited RAM
def limit_download_size(megabytes, download_list)
  return download_list if download_list_size(download_list) < megabytes.to_f

  total_size = 0.0
  count = -1
  results = []

  while total_size < megabytes.to_f
    results.push(download_list[count += 1])
    total_size += download_list[count].size
  end

  results
end

# Splits the list into parts to be divided among threads.
def split_download_list(files_to_download, num)
  split_size = (files_to_download.length / num.to_f).ceil

  files_to_download.each_slice(split_size).to_a
end

# Recursive method to clean all files and directories in the path.
def cleanup_folder(path)
  Dir.entries(path).select do |f|
    unless f == '.' || f == '..'
      if File.directory? File.join(path, f)
        cleanup_folder(File.join(path, f))
        Dir.rmdir(File.join(path, f))
      else
        File.delete(File.join(path, f))
      end
    end
  end
end

# The procedure:
# - Load config file
# - Scrape links from omgili
# - Load record of previous downloads to avoid duplicates
# - Generate a list of new links to download
# - Split download list into parts
# - Start four threads to download files simultaneously
# - After each download, send zip to have contents extracted
# - Push new content to redis list
# - Make a record of the zip that was downloaded for future executions
puts 'omgili-aggregator v0.1 - by John Walker'

previous_downloads_csv = 'previous_downloads.csv'
temp_path = 'temp/'
redis_list = 'NEWS_XML'
download_manager = DownloadManager.new
unzipper = Unzipper.new
easy_csv = EasyCSV.new(previous_downloads_csv)
config = ConfigParser.configure_with('config.yaml')
redis_pusher = RedisPusher.new(config[:host],
                               config[:port],
                               config[:db],
                               config[:require_pass],
                               redis_list)

cleanup_folder(temp_path)

scrape_results = Scraper.new.scrape

previous_downloads = easy_csv.read(previous_downloads_csv)

files_to_download = []
if previous_downloads.nil?
  files_to_download = scrape_results
else
  files_to_download =
    generate_download_list(previous_downloads, scrape_results)
end

if files_to_download.empty?
  puts 'There are no new files to download at this time.'
  puts 'Please try again later. Execution will now terminate.'
  abort
end

unless config[:download_limit].zero?
  puts "Limiting download size to ~#{config[:download_limit]}MB."
  files_to_download = limit_download_size(config[:download_limit],
                                          files_to_download)
end

progress_publisher = ProgressPublisher.new(
  files_to_download.length,
  download_list_size(files_to_download),
  redis_list
)

download_manager.add_observer(unzipper)
download_manager.add_observer(easy_csv)
download_manager.add_observer(progress_publisher)
unzipper.add_observer(redis_pusher)
redis_pusher.add_observer(progress_publisher, :update_from_redis_pusher)

download_groups = split_download_list(files_to_download, config[:threads])

threads = []
(0..(download_groups.length - 1)).each do |i|
  threads << Thread.new do
    download_manager.download(temp_path, download_groups[i])
  end
end

threads.each(&:join)
