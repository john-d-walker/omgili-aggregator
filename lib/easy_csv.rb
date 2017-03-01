# easy_csv.rb

require 'csv'

# Simplifies CSV I/O operations.
class EasyCSV
  attr_reader :save_path

  def initialize(save_path)
    @save_path = save_path
  end

  # Returns csv file contents in a string array, or nil if file does not exist.
  def read(path)
    return nil unless File.exist?(path)

    file_contents = []
    CSV.read(path).each do |contents|
      contents.each do |item|
        file_contents.push(item)
      end
    end

    file_contents
  end

  # Writes the array to a .csv file.
  def write(path, array)
    return nil if path.nil? || array.nil?

    CSV.open(path, 'a') do |file|
      file << array
    end
  end

  def update(filename, _)
    write(@save_path, [File.basename(filename)])
  end
end
