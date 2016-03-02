require 'git'

module Bundler::Advise
  class Advisories
    attr_reader :dir, :repo

    def initialize(dir: File.expand_path('~/.ruby-advisory-db'),
                   repo: 'git@github.com:rubysec/ruby-advisory-db.git')
      @dir = dir
      @repo = repo
    end

    def ensure_latest
      pull
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
