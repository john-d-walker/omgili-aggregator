task :default => :test
task :test do
  Dir.glob('./test/*.rb').each do |file|
    require file
  end
end
