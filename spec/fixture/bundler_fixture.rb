class BundlerFixture
  def self.create_lockfile(dir:, gem_specs:)
    index = Bundler::Index.new
    deps = []
    gem_specs.each do |g|
      index << g
      deps << Bundler::DepProxy.new(Bundler::Dependency.new(g.name, g.version), g.platform)
    end
    spec_set = Bundler::Resolver.resolve(deps, index)

    sources = Bundler::SourceList.new
    sources.add_rubygems_remote('https://rubygems.org')
    spec_set.each { |s| s.source = sources.rubygems_sources.first }

    gemfile_fn = File.join(dir, 'Gemfile.lock')
    defn = Bundler::Definition.new(gemfile_fn, deps.map(&:dep), sources, true)
    defn.instance_variable_set('@index', index)
    defn.instance_variable_set('@resolve', spec_set)
    defn.lock(gemfile_fn)
  end

  def self.create_spec(name, version, dependencies={})
    Gem::Specification.new do |s|
      s.name = name
      s.version = Gem::Version.new(version)
      s.platform = 'ruby'
      dependencies.each do |name, requirement|
        s.add_dependency name, requirement
      end
    end
  end
end
