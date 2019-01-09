require 'git'

module Bundler::Advise
  class Advisories
    attr_reader :dir, :repo

    def initialize(dir: File.expand_path('~/.ruby-advisory-db'),
                   repo: 'https://github.com/rubysec/ruby-advisory-db.git')
      @dir = dir
      @repo = repo
    end

    def update
      dir_missing_or_empty ? clone : pull
    rescue ArgumentError => e
      # git gem is dorky in this case, putting the path into the backtrace.
      msg = "Unexpected problem with working dir for advisories: #{e.message} #{e.backtrace}.\n" +
        "Call clean_update! to remove #{@dir} and re-clone it."
      raise RuntimeError, msg
    end

    def dir_missing_or_empty
      !File.exist?(@dir) || Dir.empty?(@dir)
    end

    def clean_update!
      FileUtils.rmtree @dir
      update
    end

    def gem_advisories_for(gem_name)
      # Sorting the results isn't strictly needed but provides deterministic
      # results for testing.
      Dir[File.join(@dir, 'gems', gem_name, '*.yml')].sort.map do |ad_yml|
        Advisory.from_yml(ad_yml)
      end
    end

    private

    def clone
      Git.clone(@repo, @dir)
    end

    def pull
      # git gem uses --git-dir and --work-tree so this SHOULD work when OS working dir
      # doesn't match - but that's not always true, so let's ensure this works on all
      # CI boxen out there.
      Dir.chdir(@dir) do
        git = Git.open(@dir)
        git.pull
      end
    end
  end
end

class Dir
  def self.empty?(path)
    Dir.glob("#{ path }/{*,.*}") do |e|
      return false unless %w( . .. ).include?(File::basename(e))
    end
    return true
  end
end
