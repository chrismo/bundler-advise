$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'bundler/advise'

include Bundler::Advise

RSpec.configure do |c|
  c.expect_with(:rspec) { |co| co.syntax = :should }
end

require_relative 'fixture/bundler_fixture'

def fixture_dir
  File.expand_path('../fixture', __FILE__)
end
