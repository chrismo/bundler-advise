require 'yaml'
require 'date'

module Bundler::Advise
  class Advisory
    def self.from_yml(yml_filename)
      id = File.basename(yml_filename, '.yml')
      if Gem::Version.new(Psych::VERSION) < Gem::Version.new('4.0.0')
        new(YAML.load(File.read(yml_filename)).tap { |h| h[:id] = id })
      else
        new(YAML.safe_load_file(yml_filename, permitted_classes: [Date]).tap { |h| h[:id] = id })
      end
    end

    def self.fields
      [:gem, :cve, :cvss_v2, :date, :description, :framework, :osvdb, :patched_versions,
       :platform, :related, :title, :unaffected_versions, :url, :vendor_patch]
    end

    attr_reader *self.fields, :id

    # Not always guaranteed to be set, but will be set by GemAdviser when scanning a lockfile.
    attr_reader :gem_spec
    attr_writer :gem_spec
    private :gem_spec=

    def initialize(fields={})
      fields.each do |k, v|
        instance_variable_set("@#{k}", v)
      end
    end

    def to_yaml
      self.class.fields.reduce({}) { |h, f| v = instance_variable_get("@#{f}"); h[f.to_s] = v if v; h }.to_yaml
    end

    def unaffected_versions
      Array(@unaffected_versions).map { |v| Gem::Requirement.create(v.split(",")) }
    end

    def patched_versions
      Array(@patched_versions).map { |v| Gem::Requirement.create(v.split(",")) }
    end

    def is_affected?(gem_version)
      is_not_patched?(gem_version) && is_not_unaffected?(gem_version)
    end

    def is_not_patched?(gem_version)
      patched_versions.detect do |pv|
        pv.satisfied_by?(Gem::Version.create(gem_version))
      end.nil?
    end

    def is_not_unaffected?(gem_version)
      unaffected_versions.detect do |pv|
        pv.satisfied_by?(Gem::Version.create(gem_version))
      end.nil?
    end
  end
end
