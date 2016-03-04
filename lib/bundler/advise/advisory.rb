require 'yaml'

module Bundler::Advise
  class Advisory
    def self.from_yml(yml_filename)
      new(YAML.load(File.read(yml_filename)))
    end

    def self.fields
      [:gem, :url, :title, :date, :description, :unaffected_versions, :patched_versions]
    end

    attr_reader *self.fields

    def initialize(fields)
      fields.each do |k, v|
        send("#{k}=".to_sym, v)
      end
    end

    def to_yaml
      self.class.fields.reduce({}) { |h, f| h[f.to_s] = instance_variable_get("@#{f}"); h }.to_yaml
    end

    private

    attr_writer(*self.fields)

    def unaffected_versions
       Array(@unaffected_versions).map { |v| Gem::Requirement.create(v) }
    end

    def patched_versions
      Array(@patched_versions).map { |v| Gem::Requirement.create(v) }
    end
  end
end
