require 'bundler/lockfile_parser'

module Bundler::Advise
  class GemAdviser
    def initialize(advisories: Advisories.new, dir: Dir.pwd)
      @advisories = advisories
      @dir = dir
      scan_lockfile
    end

    def scan_lockfile
      lockfile = nil
      Dir.chdir(@dir) do
        puts '*' * 80
        File.open(File.join(@dir, 'foo.txt'), 'w') { |f| f.print 'la' * 80 }
        puts Dir[File.join(@dir, '**', '*')].inspect
        puts '*' * 80
        lockfile = Bundler::LockfileParser.new(Bundler.read_file(File.join(@dir, 'Gemfile.lock')))
      end
      lockfile.specs.map do |spec|
        @advisories.gem_advisories_for(spec.name).select do |ad|
          ad.is_affected?(spec.version).tap { |res| ad.send(:gem_spec=, spec) if res }
        end
      end.flatten
    end
  end
end
