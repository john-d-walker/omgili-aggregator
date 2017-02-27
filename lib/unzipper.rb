# unzipper.rb

require 'zip'
require 'observer'

class Unzipper
  include Observable

  def unzip(zip_path, save_path)
    xml_paths = Array.new
    Zip::File.open(zip_path) do |zip_file|
      zip_file.each do |xml_file|
        zip_file.extract(xml_file, "#{save_path}#{xml_file}")
        xml_paths.push(save_path + "#{xml_file}")
      end
    end
    changed
    notify_observers(xml_paths)
  end

  # extracts files to a new directory named after the zip
  def update(zip_path)
    extract_path = zip_path.chomp(".zip") + "/"
    unless File.exists?(extract_path)
      Dir.mkdir(extract_path)
    end
    unzip(zip_path, extract_path)
  end
end

