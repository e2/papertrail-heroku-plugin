require 'remote_syslog_logger'

# File with pid for matching logs
PID_FILE = "fixtures/vcr_cassettes/pid"

def vcr_pid
  @pid ||= File.exist?(PID_FILE) ? IO.read(PID_FILE).to_i : Process.pid
end

Before do
  if live?
    papertrail = conf['papertrail']['syslog']
    @logger = RemoteSyslogLogger.new(papertrail['host'], papertrail['port'])
  end
end

at_exit do
  File.open(PID_FILE,'w') do |f|
    f.puts Process.pid.to_s
  end unless File.exist? PID_FILE
end

Given /^the following events are logged:$/ do |string|
  if live?
    #NOTE: lost UDP packets may cause tests to fail
    string.lines.map(&:strip).map { |line| @logger.warn line }
    sleep 2
  end
end

Then /^I should see these logs:$/ do |expected|
  # sort by event date, not log date
  regexp = / cucumber: W, \[(.*)##{vcr_pid}\]\s*WARN -- : (.*)$/
  msgs = all_stdout.lines.grep(regexp) {|_| [$1,$2] }.sort.map(&:last)
  msgs.should == expected.lines.map(&:strip)
end

Given /^I configure the papertrail addon within "([^"]*)"$/ do |app_dir|
  #TODO: fix when papertrail addon is present
  token = conf['papertrail']['addon']['token']
  cmd = "heroku config:add PAPERTRAIL_API_TOKEN=#{token}"
  step %Q{I successfully `#{cmd}` within "#{app_dir}"}
end

When /^I install heroku\-papertrail$/ do
  step %Q{I successfully `heroku plugins:install file://#{Dir.pwd}`}

  %w(init.rb lib/papertrail.rb).each do |filename|
    target = ".heroku/plugins/#{File.basename(Dir.pwd)}/#{filename}"
    overwrite_file(target, IO.read(filename))
  end
end
