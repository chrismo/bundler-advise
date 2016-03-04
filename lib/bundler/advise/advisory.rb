require 'yaml'

module Bundler::Advise
  class Advisory
    def self.from_yml(yml_filename)
      id = File.basename(yml_filename, '.yml')
      new(YAML.load(File.read(yml_filename)).tap { |h| h[:id] = id })
    end

    def self.fields
      [:gem, :url, :title, :date, :description, :unaffected_versions, :patched_versions]
    end

    attr_reader *self.fields, :id

    def initialize(fields={})
      fields.each do |k, v|
        instance_variable_set("@#{k}", v)
      end
    end

    def to_yaml
      self.class.fields.reduce({}) { |h, f| h[f.to_s] = instance_variable_get("@#{f}"); h }.to_yaml
    end

    def unaffected_versions
      Array(@unaffected_versions).map { |v| Gem::Requirement.create(v) }
    end

    def patched_versions
      Array(@patched_versions).map { |v| Gem::Requirement.create(v) }
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
