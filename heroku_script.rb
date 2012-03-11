#!/usr/bin/env ruby
# This file replaces heroku command to use VCR/Webmock
require 'bundler/setup'
require 'vcr'
require 'webmock'
require 'heroku/cli'

VCR.configure do |c|
  c.cassette_library_dir = ENV['VCR_CASSETTE_DIR']
  c.hook_into :webmock
  conf = YAML.load_file(ENV['TEST_CONFIG_FILE'])

  heroku = conf['heroku']
  c.filter_sensitive_data('<HEROKU_TOKEN>') { heroku['token'] }
  c.filter_sensitive_data('<EMAIL>') { heroku['email'] }
  c.filter_sensitive_data('<HEROKU_LOGIN>') { heroku['email'].gsub('@','%40') }

  pt = conf['papertrail']
  c.filter_sensitive_data('<PAPERTRAIL_TOKEN>') { pt['addon']['token'] }
  c.filter_sensitive_data('<PAPERTRAIL_PORT>') { pt['syslog']['port'].to_s }
  vcr = conf['vcr_filtering']
  c.filter_sensitive_data('<LOGGED_IP>') { vcr['ip'] }

  c.filter_sensitive_data('<HOSTNAME>') { Socket.gethostname }
end

def cassette_name
  "heroku #{ARGV[0]} #{ENV['FEATURE_TITLE']}".tr(' ','_')
end

VCR.use_cassette(cassette_name) do
  Heroku::CLI.start(*ARGV)
end
