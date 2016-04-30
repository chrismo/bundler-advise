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
      File.exist?(@dir) ? pull : clone
    rescue ArgumentError => e
      # git gem is dorky in this case, putting the path into the backtrace.
      msg = "Unexpected problem with working dir for advisories: #{e.message} #{e.backtrace}.\n" +
        "Call clean_update! to remove #{@dir} and re-clone it."
      raise RuntimeError, msg
    end

    def clean_update!
      FileUtils.rmtree @dir
      update
    end

    def gem_advisories_for(gem_name)
      Dir[File.join(@dir, 'gems', gem_name, '*.yml')].map do |ad_yml|
        Advisory.from_yml(ad_yml)
      end
    end

    private

    def clone
      Git.clone(@repo, @dir)
    end

    def pull
      git = Git.open(@dir)
      git.pull
    end
  end
end
