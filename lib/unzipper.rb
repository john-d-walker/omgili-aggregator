# unzipper.rb

require 'zip'
require 'observer'

# Unzips a file and stores its contents in memory.
class Unzipper
  include Observable
  attr_reader :files_to_delete, :extracted_files

  def initialize
    @files_to_delete = []
    @extracted_files = []
  end

  # Returns the extracted contents in an array.
  def unzip(zip_path, save_path)
    Zip::File.open(zip_path) do |zip_file|
      zip_file.each do |file|
        full_path = "#{save_path}#{file}"
        @files_to_delete.push(full_path)
        zip_file.extract(file, full_path)
        @extracted_files.push(File.open(full_path, 'rb').read)
      end
    end

    delete_old_files(save_path)
  end

  def delete_old_files(save_path)
    @files_to_delete.each do |file|
      File.delete(file)
    end

    @files_to_delete = []

    Dir.rmdir(save_path)

    File.delete("#{save_path[0...-1]}.zip")

    changed
    notify_observers(extracted_files)
  end

  # Extracts files to a new directory named after the zip.
  def update(zip_path, _)
    extract_path = zip_path.chomp('.zip') + '/'

    Dir.mkdir(extract_path) unless File.exist?(extract_path)

    unzip(zip_path, extract_path)
  end
end
