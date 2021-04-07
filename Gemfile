source "https://rubygems.org"

gemspec

gem "inspec-bin"

if Gem.ruby_version.to_s.start_with?("2.5")
  # 16.7.23 required ruby 2.6+
  gem "chef-utils", "< 16.7.23" # TODO: remove when we drop ruby 2.5
end

group :development do
  gem "chefstyle", "1.7.4"
  gem "m"
  gem "bundler"
  gem "byebug"
  gem "minitest"
  gem "rake"
  gem "rubocop"
end