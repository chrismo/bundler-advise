require_relative '../spec_helper'

describe Advisory do
  it 'should parse the yummy yml' do
    ad = Advisory.from_yml(File.join(fixture_dir, 'gems', 'bar', 'bar-1_0_1.yml'))
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
