require_relative '../spec_helper'

describe Advisories do
  it 'should default to home dir' do
    Advisories.new.dir.should == File.expand_path('~/.ruby-advisory-db')
  end

  it 'should default to rubysec ruby-advisory-db' do
    Advisories.new.repo.should == 'git@github.com:rubysec/ruby-advisory-db.git'
  end

  it 'should clone if no copy exists'

  it 'should pull if working dir exists'

  it 'should error handle messed up dir'
end
