# scraper.rb
require 'rubygems'
require 'nokogiri'
require 'open-uri'

# link: full download link for zip. size: in MB
ZipData = Struct.new(:link, :size)

class Scraper
  FEED_URL = "http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/"
  
  # Returns an array of ZipData.
  def scrape
    html = Nokogiri::HTML(open(FEED_URL))

    zip_data = Array.new

    (3..html.css('tr').length - 2).each do |i| # Data starts at tr[3] and ends at tr[n-2].
      row = html.css('tr')[i]
      zip_data.push(ZipData.new(FEED_URL + row.css('a').text,
                                row.css('td')[2].text[0...-1].to_f))
    end
    
    return zip_data
  end
end

