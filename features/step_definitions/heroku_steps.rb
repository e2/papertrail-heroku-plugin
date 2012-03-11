ENV['VCR_CASSETTE_DIR'] = File.join(File.dirname(__FILE__),
                                     *%w(.. .. fixtures vcr_cassettes))

Before do |feature|
  @apps_to_destroy = []
  ENV['FEATURE_TITLE'] = feature.title
end

After do
  #TODO: have user confirm anyway?
  while (app = @apps_to_destroy.shift)
    original_heroku = Gem.bin_path('heroku')
    step %Q{I successfully run `#{original_heroku} apps:destroy #{app} --confirm #{app}`}
  end if live?
end

Given /^I add "([^"]*)" to heroku$/ do |app_dir|
  heroku = conf['heroku']

  create_dir('.heroku')
  write_file('.heroku/credentials', "#{heroku['email']}\n#{heroku['token']}")

  step %Q{I successfully `heroku create` within "#{app_dir}"}
  sleep 5 if live?
end

Given /^I( successfully)? `(heroku [^`]*)`(?: within "([^"]*)")?$/ do |successfully, cmd, app_dir|
  cd(app_dir) if app_dir

  FileUtils.cp('heroku_script.rb', File.join(dirs.first, 'heroku'),
               :preserve => true)
  step %Q{I#{successfully} run `#{cmd}`}

  if cmd =~ /^heroku (?:apps:)?create(?:$|\s)/
    match = /http:\/\/(.*)\.heroku\.com/.match(output_from(cmd))
    @apps_to_destroy << match[1] if match
  end

  cd('..') if app_dir
end
