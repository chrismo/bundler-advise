require_relative '../spec_helper'

describe Advisory do
  context 'persistence' do
    it 'should parse the yummy yml' do
      ad = Advisory.from_yml(File.join(fixture_dir, 'gems', 'bar', 'bar-1_0_1.yml'))
      ad.id.should == 'bar-1_0_1'
      ad.gem.should == 'bar'
      ad.url.should == 'http://bar-gem-is-awesome.com'
      ad.title.should == 'bar 1.0.1 might explode your spleen'
      ad.date.should == DateTime.parse('2015-11-18')
      ad.description.should == 'This version could, like, explode your spleen if taken internally'
      ad.unaffected_versions.should == [Gem::Requirement.create('1.0.0')]
      ad.patched_versions.should == [Gem::Requirement.create('>= 1.0.2')]
    end

    it 'should output back to yaml as hash' do
      yml_fn = File.join(fixture_dir, 'gems', 'bar', 'bar-1_0_1.yml')
      actual_yml = File.read(yml_fn)
      ad = Advisory.from_yml(yml_fn)
      ad.to_yaml.should == actual_yml
    end
  end

  it 'should determine if patched' do
    ad = Advisory.new(patched_versions: '>= 1.4.3')
    ad.is_not_patched?('1.4.2').should be true
    ad.is_not_patched?('1.4.3').should be false
    ad.is_not_patched?('1.4.4').should be false

    ad.is_affected?('1.4.2').should be true
    ad.is_affected?('1.4.3').should be false
    ad.is_affected?('1.4.4').should be false
  end

  it 'should determine if unaffected' do
    ad = Advisory.new(unaffected_versions: '>= 1.4.3')
    ad.is_not_unaffected?('1.4.2').should be true
    ad.is_not_unaffected?('1.4.3').should be false
    ad.is_not_unaffected?('1.4.4').should be false

    ad.is_affected?('1.4.2').should be true
    ad.is_affected?('1.4.3').should be false
    ad.is_affected?('1.4.4').should be false
  end

  it 'should have sane defaults if patched and unaffected not specified' do
    ad = Advisory.new
    ad.is_not_unaffected?('1.4.2').should be true
    ad.is_not_patched?('1.4.2').should be true
    ad.is_affected?('1.4.2').should be true
  end

  it 'should work well if both specified' do
    ad = Advisory.new(unaffected_versions: '< 1.3.0', patched_versions: '>= 1.4.3')
    ad.is_affected?('1.2.0').should be false
    ad.is_affected?('1.3.9').should be true
    ad.is_affected?('1.4.2').should be true
    ad.is_affected?('1.4.3').should be false
  end
end
