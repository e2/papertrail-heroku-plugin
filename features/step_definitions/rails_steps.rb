Given /^I have a rails app "([^"]*)" with git$/ do |app_name|
  run_simple("rails new #{app_name} --skip-bundle -T -q")
  cd(app_name)
  run_simple('git init')
  run_simple('git add -A')
  run_simple('git commit -m "first commit"')
  cd('..')
end
