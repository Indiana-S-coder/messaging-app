module Utility
  def self.load_yaml(path)
    YAML.load_file(Rails.root.join(path))
  rescue StandardError => e
    Rails.logger.error "Error loading YAML file at #{path}: #{e.message}"
    {}
  end
end
