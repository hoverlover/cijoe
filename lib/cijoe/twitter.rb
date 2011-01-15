require 'multi_json'

class CIJoe
  module Twitter
    CONFIG_VARS = %w[consumer_key consumer_secret oauth_token oauth_token_secret]

    def self.activate
      if valid_config?
        require 'twitter'

        ::Twitter.configure do |config|
          config.consumer_key = self.config.consumer_key.to_s
          config.consumer_secret = self.config.consumer_secret.to_s
          config.oauth_token = self.config.oauth_token.to_s
          config.oauth_token_secret = self.config.oauth_token_secret.to_s
        end

        CIJoe::Build.class_eval do
          include CIJoe::Twitter
        end

        puts "Loaded Twitter notifier"
      else
        puts "Can't load Twitter notifier."
        puts "Please add the following to your Heroku config vars:"
        CONFIG_VARS.each { |var| puts "\t#{var}" }
      end
    end

    def self.config
      @config ||= Config.new('twitter')
    end

    def self.valid_config?
      CONFIG_VARS.all? do |key|
        !config.send(key).to_s.empty?
      end
    end

    def notify
      url = worked? ? commit.url : Config.cijoe.ci_server_url.to_s
      ::Twitter.update(truncate_if_necessary(build_status, Bitly.shorten(url)))
    end

  private
    def build_status
      parts = [short_sha, status || "failed"]
      parts + [commit.author, commit.message].join(':') if commit
      parts.compact.join(' ')
    end

    def truncate_if_necessary(status, ci_server_url = nil)
      status.strip!

      max_length = 140

      # If a URL was passed in, shorten it and subtract from the max_length
      if ci_server_url
        ci_server_url.strip!
        max_length -= ci_server_url.length
      end

      parts = [status, ci_server_url].compact

      # Add a truncation identifier to the status if the sum of the combined parts length > max_length
      if parts.inject(0) { |len, part| len + part.length } > max_length
        parts.insert(1, "(truncated)")
        max_length -= parts[1].length
      end

      # Allow for the number of spaces that will be added by the spaces in the join below
      max_length -= parts.length - 1
      parts[0] = parts[0][0...max_length]

      puts "status = #{parts.join(" ")}"
      parts.join(" ")
    end
  end
end
