require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Dnd5eQic
  class Application < Rails::Application
    config.load_defaults 7.1

    config.autoload_lib(ignore: %w(assets tasks))

    # 日本語化
    config.i18n.default_locale = :ja
  end
end
