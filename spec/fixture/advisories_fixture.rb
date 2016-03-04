class AdvisoriesFixture
  attr_reader :dir

  def initialize
    @dir = File.join(Dir.tmpdir, 'advisory_db')
    FileUtils.makedirs @dir
  end

  def clean_up
    FileUtils.rmtree @dir
  end

  def save_advisory(ad)
    gem_path = File.join(@dir, 'gems', ad.gem)
    FileUtils.makedirs gem_path
    last_fn = Dir[File.join(gem_path, '*yml')].last || '000.yml'
    next_fn = "#{File.basename(last_fn, '.yml').next}.yml"
    File.open(File.join(gem_path, next_fn), 'wb') { |f| f.print ad.to_yaml }
  end
end
