# csv_tool.rb

require 'csv'

class CSVTool
  # Returns csv file contents in a string array, or nil if file does not exist.
  def read(path)
    if File.exists?(path)
      file_contents = Array.new
      CSV.read(path).each do |contents|
        contents.each do |item|
          file_contents.push(item)
        end
      end
      return file_contents
    else
      return nil
    end
  end

  # Writes the array to a .csv file.
  def write(path, array)
    if (path.nil? || array.nil?)
      return nil
    end
    CSV.open(path, 'a') do |file|
      file << array
    end
    return true
  end
end

