require 'aruba/cucumber'

Before do
  @aruba_timeout_seconds = 40

  @old_home = ENV['HOME']
  ENV['HOME'] = File.expand_path(dirs.first)

  @old_path = ENV['PATH']
  ENV['PATH'] = "#{File.expand_path(dirs.first)}:#{ENV['PATH']}"
end

After do
  ENV['PATH'] = @old_path
  ENV['HOME'] = @old_home
end
