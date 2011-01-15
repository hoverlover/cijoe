class CIJoe
  module Bitly
    require 'bitly'
    ::Bitly.use_api_version_3

    CONFIG_VARS = %w[user_name api_key]

    def self.shorten(url)
      if valid_config?
        ::Bitly.new(config.user_name.to_s, config.api_key.to_s).shorten(url).short_url
      else
        puts "Can't shorten URL due to missing config variables.  Please add the foloowing to your Heroku config vars:"
        CONFIG_VARS.each { |var| puts "\t#{var}" }
        nil
      end
    end

    def self.config
      @config ||= Config.new('bitly')
    end

    def self.valid_config?
      CONFIG_VARS.all? do |key|
        !config.send(key).to_s.empty?
      end
    end
  end
end
