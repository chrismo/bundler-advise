module Bundler::Advise
  class GemAdviser
    def initialize(advisories: [], dir: Dir.pwd)
      @advisories = advisories
      @dir = dir
      scan_lockfile
    end

    def scan_lockfile
      lockfile = nil
      Dir.chdir(@dir) do
        lockfile = Bundler::LockfileParser.new(Bundler.read_file('Gemfile.lock'))
      end
      lockfile.specs.map do |spec|
        @advisories
      end
    end
  end
end
