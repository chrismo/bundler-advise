module Bundler::Advise
  class GemAdviser
    def initialize(advisories:, dir: Dir.pwd)
      @advisories = advisories
      @dir = dir
      scan_lockfile
    end

    def scan_lockfile
      Dir.chdir(@dir) do
        lockfile = Bundler::LockfileParser(Bundler.read_file('Gemfile.lock'))
      end
      lockfile.specs
    end
  end
end
