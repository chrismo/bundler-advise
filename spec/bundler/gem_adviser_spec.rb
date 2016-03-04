require_relative '../spec_helper'

describe GemAdviser do
  before do
    @dir = File.join(Dir.tmpdir, 'gem_adviser_spec')
    FileUtils.makedirs @dir
    BundlerFixture.create_lockfile(dir: @dir, gem_specs: [
      BundlerFixture.create_spec('foo', '1.2.3', {'quux' => '~> 1.4'}),
      BundlerFixture.create_spec('bar', '5.6'),
      BundlerFixture.create_spec('quux', '1.4.3')
    ])
  end

  def dump
    puts File.read(File.join(@dir, 'Gemfile.lock'))
  end

  after do
    FileUtils.rmtree @dir
  end

  it 'should load vulnerability' do
    GemAdviser.new(dir: @dir, advisories: [

    ])
  end
end
