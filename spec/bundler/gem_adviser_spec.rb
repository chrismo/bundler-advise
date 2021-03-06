require_relative '../spec_helper'
require 'tmpdir'

describe GemAdviser do
  before do
    @bf = BundlerFixture.new
    @bf.create_lockfile(
      gem_dependencies: [@bf.create_dependency('foo'),
                         @bf.create_dependency('bar'),
                         @bf.create_dependency('quux')],
      source_specs: [
        @bf.create_spec('foo', '1.2.3', {'quux' => '~> 1.4'}),
        @bf.create_spec('bar', '5.6'),
        @bf.create_spec('quux', '1.4.3')
      ])

    @af = AdvisoriesFixture.new
  end

  def dump
    puts @bf.lockfile_contents
  end

  after do
    @af.clean_up
    @bf.clean_up
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

  it 'should include gem spec from lockfile' do
    @af.save_advisory(Advisory.new(gem: 'quux', patched_versions: '>= 1.4.5'))
    ga = GemAdviser.new(dir: @bf.dir, advisories: Advisories.new(dir: @af.dir))
    advisory = ga.scan_lockfile.first
    advisory.gem_spec.name.should == 'quux'
    advisory.gem_spec.version.to_s.should == '1.4.3'
  end

  it 'should obey the BUNDLE_GEMFILE env var' do
    begin
      Dir.chdir(Dir.tmpdir) do
        Bundler.with_original_env do
          ENV['BUNDLE_GEMFILE'] = File.join(@bf.dir, 'Gemfile')
          @af.save_advisory(Advisory.new(gem: 'quux', patched_versions: '>= 1.4.5'))
          ga = GemAdviser.new(advisories: Advisories.new(dir: @af.dir))
          ga.scan_lockfile.map(&:gem).should == ['quux']
        end
      end
    ensure
      # TODO: necessary?
      # ENV['BUNDLE_GEMFILE'] = nil
    end
  end
end
