require 'fileutils'

def live?
  !File.exist? PID_FILE
end

def conf
  filename = live? ? 'test_config.yml' : 'test_config.yml.default'
  ENV['TEST_CONFIG_FILE'] = File.expand_path(filename)
  @conf ||= YAML.load(File.read(filename))
end
