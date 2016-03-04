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
  end

  def dump
    puts File.read(File.join(@bf.dir, 'Gemfile.lock'))
  end

  after do
    FileUtils.rmtree @af.clean_up
    FileUtils.rmtree @bf.clean_up
  end

  it 'should find one matching advisories' do
    @af.save_advisory(Advisory.new(gem: 'quux', patched_versions: '>= 1.4.5'))
    ga = GemAdviser.new(dir: @bf.dir, advisories: Advisories.new(dir: @af.dir))
    ga.scan_lockfile.map(&:gem).should == ['quux']
  end

  it 'should not find one non-matching advisories' do
    @af.save_advisory(Advisory.new(gem: 'quux', patched_versions: '>= 1.4.2'))
    ga = GemAdviser.new(dir: @bf.dir, advisories: Advisories.new(dir: @af.dir))
    ga.scan_lockfile.map(&:gem).should be_empty
  end

  it 'should find one matching from many advisories' do
    @af.save_advisory(Advisory.new(gem: 'quux', patched_versions: '>= 1.4.5'))
    @af.save_advisory(Advisory.new(gem: 'quux', patched_versions: '>= 1.4.2'))
    ga = GemAdviser.new(dir: @bf.dir, advisories: Advisories.new(dir: @af.dir))
    ga.scan_lockfile.map(&:gem).should == ['quux']
  end

  it 'should find many matching from many advisories' do
    @af.save_advisory(Advisory.new(gem: 'quux', date: '2014-01-12', patched_versions: '>= 1.4.5'))
    @af.save_advisory(Advisory.new(gem: 'quux', date: '2014-01-13', patched_versions: '>= 1.4.4'))
    ga = GemAdviser.new(dir: @bf.dir, advisories: Advisories.new(dir: @af.dir))
    ga.scan_lockfile.map(&:date).should == ['2014-01-12', '2014-01-13']
  end

  it 'should find many gems matching from many advisories' do
    @af.save_advisory(Advisory.new(gem: 'quux', patched_versions: '>= 1.4.5'))
    @af.save_advisory(Advisory.new(gem: 'bar', patched_versions: '>= 6.0'))
    ga = GemAdviser.new(dir: @bf.dir, advisories: Advisories.new(dir: @af.dir))
    ga.scan_lockfile.map(&:gem).should == ['bar', 'quux']
  end

  it 'should skip matching but unaffected' do
    @af.save_advisory(Advisory.new(gem: 'quux',
                                   unaffected_versions: '~> 1.4.0',
                                   patched_versions: '>= 1.6.0'))
    ga = GemAdviser.new(dir: @bf.dir, advisories: Advisories.new(dir: @af.dir))
    ga.scan_lockfile.map(&:gem).should be_empty
  end
end
