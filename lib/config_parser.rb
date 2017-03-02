require 'yaml'

# Parses the config.yaml file.
# Code taken from the accepted answer of the question:
# http://stackoverflow.com/questions/6233124/where-to-place-access-config-file-in-gem
module ConfigParser
  # Defaults
  @default_config = {
    host: '127.0.0.1',
    port: 6379,
    db: 0,
    require_pass: false,
    threads: 2,
    download_limit: 1024
  }.freeze

  @config = {
    host: '127.0.0.1',
    port: 6379,
    db: 1,
    require_pass: false,
    threads: 2,
    download_limit: 1024
  }

  @valid_config_keys = @config.keys

  # Configure through hash
  def self.configure(opts = {})
    opts.each do |k, v|
      @config[k.to_sym] = v if @valid_config_keys.include? k.to_sym
    end
    @config
  end

  # Configure through yaml file
  def self.configure_with(path_to_yaml_file)
    begin
      config = YAML.safe_load(IO.read(path_to_yaml_file))
    rescue Errno::ENOENT
      puts 'YAML config file not found. Using defaults.'
      return @default_config
    rescue Psych::SyntaxError
      puts 'YAML config file syntax is invalid. Using defaults.'
      return @default_config
    end

    configure(config)
  end

  def self.config
    @config
  end
end
