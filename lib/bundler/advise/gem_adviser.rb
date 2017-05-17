require 'bundler/lockfile_parser'

module Bundler::Advise
  class GemAdviser
    def initialize(advisories: Advisories.new, dir: nil)
      @advisories = advisories
      @dir = dir
      scan_lockfile
    end

    def scan_lockfile
      lockfile = nil
      begin
        restore = ENV['BUNDLE_GEMFILE']
        ENV['BUNDLE_GEMFILE'] = File.join(@dir, 'Gemfile') if @dir
        lockfile = Bundler::LockfileParser.new(Bundler.read_file(Bundler.default_lockfile))
      ensure
        # restoration is probably overkill, but need to retain prior functionality
        ENV['BUNDLE_GEMFILE'] = restore
      end
      lockfile.specs.map do |spec|
        @advisories.gem_advisories_for(spec.name).select do |ad|
          ad.is_affected?(spec.version).tap { |res| ad.send(:gem_spec=, spec) if res }
        end
      end.flatten
    end
  end
end
