require 'capybara'
require 'rspec'
require 'capybara/cucumber'

## Uncomment to enable SimpleCov
#require 'simplecov'

#SimpleCov.start do
#  add_filter 'features/'
#end

## Replace with path to your controller 
#require_relative '../../login_example'

ENV['RACK_ENV'] = 'test'

Capybara.app = Sinatra::Application

class Sinatra::ApplicationWorld
  include RSpec::Expectations
  include RSpec::Matchers
  include Capybara::DSL
end

World do
	Sinatra::ApplicationWorld.new  
end



