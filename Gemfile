source 'https://rubygems.org'

group :development do
  gem "puppet-blacksmith"
  gem "github_changelog_generator"
end

puppetversion = ENV.key?('PUPPET_VERSION') ? "#{ENV['PUPPET_VERSION']}" : ['>= 3.3']
gem 'puppet', puppetversion
gem 'puppetlabs_spec_helper', '>= 0.8.2'
gem 'puppet-lint', '>= 1.0.0'
gem 'facter', '>= 1.7.0'
gem "json", "~> 1.8.3"
gem "json_pure", "~> 1.8.3"
gem 'metadata-json-lint'
