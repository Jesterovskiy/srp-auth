require "srp/auth/version"

module Srp
  ##
  # Module: Authentication lib
  #
  # Provide auth using SRP protocol and creation of token for user session
  #
  module Auth
    ##
    # Class: provide logic for SignIn requests
    #
    class SignIn
      TTL = 86_400
      PRIME = 2048

      def call(env)
        path = env['REQUEST_PATH'] || env['PATH_INFO']

        @srp.start(env)  if path == '/auth/start'
        @srp.finish(env) if path == '/auth/finish'
        env['sign_in'] = @srp.response
      end

    private

      def initialize
        token = Auth::Token.new
        @srp  = Auth::SRP.new(token, TTL, PRIME)
      end
    end

    class FailureApp
      def self.call(env)
        response = Rack::Response.new
        response.redirect('/auth')
        response.finish
      end
    end

  end

  require 'srp/auth/srp'
  require 'srp/auth/token'
  require 'srp/auth/reset_password'
end
