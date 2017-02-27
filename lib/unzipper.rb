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
end

