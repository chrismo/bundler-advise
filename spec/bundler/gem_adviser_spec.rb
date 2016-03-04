require_relative '../spec_helper'

describe GemAdviser do
  before do
    @bf = BundlerFixture.new
    @bf.create_lockfile(gem_specs: [
      @bf.create_spec('foo', '1.2.3', {'quux' => '~> 1.4'}),
      @bf.create_spec('bar', '5.6'),
      @bf.create_spec('quux', '1.4.3')
    ])

    @af = AdvisoriesFixture.new
    @af.save_advisory(Advisory.new(gem: 'quux', patched_versions: '>= 1.4.5'))
  end

  def dump
    puts File.read(File.join(@bf.dir, 'Gemfile.lock'))
  end

  after do
    FileUtils.rmtree @af.clean_up
    FileUtils.rmtree @bf.clean_up
  end

  it 'should load vulnerability' do
    ga = GemAdviser.new(dir: @bf.dir, advisories: Advisories.new(dir: @af.dir))
    ga.scan_lockfile.map(&:gem).should == ['quux']
  end
end
