require 'yaml'

module Bundler::Advise
  class Advisory
    def self.from_yml(yml_filename)
      h = YAML.load(File.read(yml_filename))
      a = new
      h.each do |k, v|
        a.send("#{k}=".to_sym, v)
      end
      a
    end

    def self.fields
      [:gem, :url, :title, :date, :description, :unaffected_versions, :patched_versions]
    end

    attr_reader *self.fields

    private

    attr_writer(*self.fields)

    def unaffected_versions=(value)
      @unaffected_versions = value.map { |v| Gem::Requirement.create(v) }
    end

    def patched_versions=(value)
      @patched_versions = value.map { |v| Gem::Requirement.create(v) }
    end
  end
end
