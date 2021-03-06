# unzipper.rb

require 'rubygems'
require 'bundler/setup'
require 'zip'
require 'observer'

# Unzips a file and stores its contents in memory.
class Unzipper
  include Observable

  # Returns the extracted contents in an array.
  def extract_to_memory(zip_path, save_path)
    files_to_delete = []
    extracted_files = []

    Zip::File.open(zip_path) do |zip_file|
      zip_file.each do |file|
        files_to_delete.push("#{save_path}#{file}")
        extract_to_file(zip_file, file, "#{save_path}#{file}")
        extracted_files.push(File.open("#{save_path}#{file}", 'rb').read)
      end
    end

    delete_old_files(save_path, files_to_delete, extracted_files)
  end

  def extract_to_file(zip_file, content, save_path)
    zip_file.extract(content, save_path)
  rescue StandardError => e
    puts e.message
  end

  def delete_old_files(save_path, files_to_delete, extracted_files)
    files_to_delete.each do |file|
      File.delete(file)
    end

    Dir.rmdir(save_path)

    File.delete("#{save_path[0...-1]}.zip")

    changed
    notify_observers(extracted_files)
  end

  # Extracts files to a new directory named after the zip.
  def update(zip_path, _)
    extract_path = zip_path.chomp('.zip') + '/'

    Dir.mkdir(extract_path) unless File.exist?(extract_path)

    extract_to_memory(zip_path, extract_path)
  end
end
