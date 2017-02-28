# unzipper.rb

require 'zip'
require 'observer'

class Unzipper
  include Observable

  # Returns the extracted contents in an array.
  def unzip(zip_path, save_path)
    extracted_files = Array.new
    files_to_delete = Array.new

    Zip::File.open(zip_path) do |zip_file|
      zip_file.each do |file|
        full_path = "#{save_path}#{file}"
        files_to_delete.push(full_path)
        zip_file.extract(file, full_path)
        extracted_files.push(File.open(full_path, "rb").read)
      end
    end

    # Now that zip contents are in memory, delete files stored on hard drive.
    files_to_delete.each do |file|
      File.delete(file)
    end

    Dir.rmdir(save_path)
    File.delete("#{save_path[0...-1]}.zip")

    changed
    notify_observers(extracted_files)
  end

  # Extracts files to a new directory named after the zip.
  def update(zip_path, item)
    extract_path = zip_path.chomp(".zip") + "/"
    unless File.exists?(extract_path)
      Dir.mkdir(extract_path)
    end
    unzip(zip_path, extract_path)
  end
end

