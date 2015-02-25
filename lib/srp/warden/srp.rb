require 'warden'

module Warden
  module SRP
    CONFIG_EXAMPLE = <<-CODE
Warden::OpenID.configure do |config|
  config.user_finder do |response|
    # do something
  end
end
    CODE

    class Config
      attr_accessor :required_fields, :optional_fields, :policy_url

      def user_finder(&block)
        @user_finder = block
      end

      def find_user(response)
        raise "Warden::SRP::Config#user_finder has not been set yet.\n\n#{Warden::OpenID::CONFIG_EXAMPLE}" unless @user_finder
        @user_finder.call(response)
      end

      def to_params
        {
          :required   => required_fields,
          :optional   => optional_fields,
          :policy_url => policy_url
        }
      end
    end

    class << self
      def config
        @@config ||= Config.new
      end

      def configure(&block)
        block.call(config)
      end

      def user_finder(&block)
        $stderr.puts "DEPRECATION WARNING: Warden::SRP.user_finder is deprecated. Use Warden::SRP::Config#user_finder instead.\n\n#{CONFIG_EXAMPLE}"

        configure do |config|
          config.user_finder(&block)
        end
      end
    end

    class Strategy < Warden::Strategies::Base
      def valid?
        @token = Rack::Request.new(env).cookies['session_token']
      end

      def authenticate!
        user = REDIS.get(@token)
        user.nil? ? fail!("Could not log in") : success!(JSON.load(user))
      end
    end
  end
end
