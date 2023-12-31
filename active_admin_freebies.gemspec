# frozen_string_literal: true

require_relative "lib/active_admin_freebies/version"

Gem::Specification.new do |spec|
  spec.name = "active_admin_freebies"
  spec.version = ActiveAdminFreebies::VERSION
  spec.authors = ["Rick Gorman"]
  spec.email = ["rickgorman@users.noreply.github.com"]

  spec.summary = "A collection of addons for active_admin"
  spec.homepage = "https://github.com/rickgorman/active_admin_freebies"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/rickgorman/active_admin_freebies"
  spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", "~> 6.0"
  spec.add_dependency "activeadmin"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
