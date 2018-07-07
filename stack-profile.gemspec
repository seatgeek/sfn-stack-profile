$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'stack-profile/version'
Gem::Specification.new do |s|
  s.name = 'stack-profile'
  s.version = StackProfileCallback::VERSION.version
  s.summary = 'SparkleFormation Stack Profile'
  s.author = 'Michael Weinberg'
  s.email = 'mweinberg@seatgeek.com'
  s.description = 'SparkleFormation Stack Profile Callback'
  s.homepage = 'https://gitlab.service.seatgeek.mgmt/infra'
  s.license = 'Nonstandard'
  s.require_path = 'lib'
  s.add_dependency 'sfn'
  s.files = Dir['lib/**/*'] + ['stack-profile.gemspec']
end
