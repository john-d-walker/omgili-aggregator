# omgili_aggregator.rb

require_relative 'scraper'
require_relative 'csv_tool'
require_relative 'download_manager'
require_relative 'unzipper'
require_relative 'redis_pusher'

class OmgiliAggregator
  def generate_download_list(csv_data, scrape_data)
    results = Array.new

    scrape_data.each do |item|
      unless csv_data.include?(item)
        results.push(item)
      end
    end

    return results
  end

  def run

  end
end

