class BundlerFixture
  def self.create_lockfile(dir:, gem_specs:)
    index = Bundler::Index.new
    deps = []
    gem_specs.each do |g|
      index << g
      deps << Bundler::DepProxy.new(Bundler::Dependency.new(g.name, g.version), g.platform)
    end
    Bundler::Resolver.resolve(deps, index)

    sources = Bundler::SourceList.new
    gemfile_fn = File.join(dir, 'Gemfile.lock')
    defn = Bundler::Definition.new(gemfile_fn, deps.map(&:dep), sources, true)
    defn.instance_variable_set('@index', index)
    defn.lock(gemfile_fn)
  end

  def self.create_spec(name, version)
    Gem::Specification.new do |s|
      s.name = name
      s.version = Gem::Version.new(version)
      s.platform = 'ruby'
    end
  end
end
