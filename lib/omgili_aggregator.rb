# omgili_aggregator.rb

require_relative 'scraper'
require_relative 'csv_tool'
require_relative 'download_manager'
require_relative 'unzipper'
require_relative 'redis_pusher'

class OmgiliAggregator
  attr_reader :previous_downloads_csv, :csv_tool, :temp_path, 
    :download_manager, :unzipper, :redis_pusher, :redis_list_name

  def initialize
    @previous_downloads_csv = "previous_downloads.csv"
    @csv_tool = CSVTool.new
    @temp_path = "temp/"
    @download_manager = DownloadManager.new
    @unzipper = Unzipper.new
    @redis_list_name = "NEWS_XML"
    @redis_pusher = RedisPusher.new(@redis_list_name)

    @download_manager.add_observer(@unzipper)
    @download_manager.add_observer(self)
    @unzipper.add_observer(@redis_pusher)
  end

  def generate_download_list(csv_data, scrape_data)
    results = Array.new

    scrape_data.each do |item|
      unless csv_data.include?(item)
        results.push(item)
      end
    end

    return results
  end

  # Used for testing with smaller datasets.
  def limit_download_size(megabytes, download_list)
    download_list_size = 0.0
    download_list.each do |item|
      download_list_size += item.size
    end
    if download_list_size < megabytes.to_f
      return download_list
    end

    total_size = 0.0
    count = 0
    results = Array.new
    while total_size < megabytes.to_f
      results.push(download_list[count])
      count += 1
      total_size += download_list[count].size
    end
    return results
  end

  # Splits the list into parts to be divided among threads.
  def split_download_list(files_to_download)
    split_size = (files_to_download.length/2.0).ceil
    return files_to_download.each_slice(split_size).to_a
  end

  # Keeps track of downloaded files.
  def update(downloaded_file_path)
    @csv_tool.write(@previous_downloads_csv, [File.basename(downloaded_file_path)])
  end

  # The procedure:
  # - Scrape links from omgili
  # - Load record of previous downloads to avoid duplicates
  # - Generate a list of new links to download
  # - Split download list into four parts
  # - Start four threads to download files simultaneously
  # - After each download, send zip to have contents extracted
  # - Push new content to redis list
  # - Make a record of the zip that was downloaded for future executions
  def run
    scrape_results = Scraper.new.scrape

    previous_downloads = @csv_tool.read(@previous_downloads_csv)

    files_to_download = Array.new
    if previous_downloads.nil?
      files_to_download = scrape_results
    else
      files_to_download = generate_download_list(previous_downloads, scrape_results)
    end

    if files_to_download.length == 0
      puts 'There are no new files to download at this time.'
      puts 'Please try again later. Execution will now terminate.'
      abort
    end

    unless (ARGV[0].nil?)
      puts 'limiting download size'
      files_to_download = limit_download_size(ARGV[0], files_to_download)
      puts files_to_download
    end

    download_groups = split_download_list(files_to_download)

    threads = []
    (0..(download_groups.length - 1)).each do |i|
      threads << Thread.new { 
        @download_manager.download(@temp_path, download_groups[i])
      }
    end

    threads.each do |thread|
      thread.join
    end
  end
end

OmgiliAggregator.new.run

