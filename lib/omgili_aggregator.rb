# omgili_aggregator.rb

require_relative 'scraper'
require_relative 'csv_tool'
require_relative 'download_manager'
require_relative 'unzipper'
require_relative 'redis_pusher'

class OmgiliAggregator
  attr_reader :previous_downloads_csv, :csv_tool, :temp_path, 
    :download_manager, :unzipper, :redis_pusher, :redis_list_name,
    :download_count, :mb_count, :download_list_size, :download_total_mb,
    :xml_pushed_count

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
    @redis_pusher.add_observer(self, :update_from_redis_pusher)

    @download_count = 0
    @mb_count = 0.0
    @download_list_size = 0
    @download_total_mb = 0.0
    @xml_pushed_count = 0
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
  def split_download_list(files_to_download, num)
    split_size = (files_to_download.length/num.to_f).ceil
    return files_to_download.each_slice(split_size).to_a
  end

  # Keeps track of what has been downloaded.
  def update(downloaded_file_path, item)
    @csv_tool.write(@previous_downloads_csv, [File.basename(downloaded_file_path)])
    @download_count += 1
    @mb_count += item.size
    output_status(item)
  end

  def output_status(item)
    percent = (@download_count.to_f / @download_list_size.to_f * 100.0).round
    end_line = (@download_count == @download_list_size ? "\n" : "\r")
    print "Progress: #{@download_count}/#{@download_list_size} files | "
    print "#{@mb_count.round}MB/#{@download_total_mb.round}MB | "
    print "#{percent}%#{end_line}"
  end

  def update_from_redis_pusher(num_pushed)
    @xml_pushed_count += num_pushed
  end

  # The procedure:
  # - Scrape links from omgili
  # - Load record of previous downloads to avoid duplicates
  # - Generate a list of new links to download
  # - Split download list into parts
  # - Start four threads to download files simultaneously
  # - After each download, send zip to have contents extracted
  # - Push new content to redis list
  # - Make a record of the zip that was downloaded for future executions
  def run
    puts 'omgili-aggregator v0.1 - by John Walker'

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
      puts "Limiting download size to ~#{ARGV[0]}MB."
      files_to_download = limit_download_size(ARGV[0], files_to_download)
    end

    @download_list_size = files_to_download.size
    files_to_download.each do |file|
      @download_total_mb += file.size
    end
    print "Progress: initializing...\r"

    download_groups = split_download_list(files_to_download, 2)

    threads = []
    (0..(download_groups.length - 1)).each do |i|
      threads << Thread.new { 
        @download_manager.download(@temp_path, download_groups[i])
      }
    end

    threads.each do |thread|
      thread.join
    end

    puts "Results: pushed #{@xml_pushed_count} XML files to #{@redis_list_name}."
  end
end

OmgiliAggregator.new.run

