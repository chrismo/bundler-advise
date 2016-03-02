$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bundler/advise'

include Bundler::Advise

RSpec.configure do |c|
  c.expect_with(:rspec) { |co| co.syntax = :should }
end
