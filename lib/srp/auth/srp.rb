require 'srp'
require 'json/jwt'

##
# Class: implemetn SRP protocol
#
class Auth::SRP

  FORM_HASH = 'rack.request.form_hash'.freeze

  ##
  # Public: first stage of SRP auth
  #
  # Params:
  # - env {} env
  #
  # Returns: {Hash} with challange
  #
  def start(env)
    @login = env[FORM_HASH]['login'].freeze
    @big_a = env[FORM_HASH]['A'].freeze
    fetch_user_params

    if @user.nil?
      auth_fail
    else
      generate_challenge
    end
  end

  ##
  # Public: last stage of SRP auth
  #
  # Params:
  # - env {} env
  #
  # Returns: {Hash} with key match and auth token
  #
  def finish(env)
    @match = env[FORM_HASH]['match']
    match_secrets
  end

  ##
  # Public: create response for application
  #
  # Returns: {Array} with status, header and body of response
  #
  def response
    [@response.status, @response.header, @response.body]
  end

private

  attr_reader :login, :A, :salt, :verifier

  ##
  # Params:
  # - token {Auth::Token} instance of Auth::Token
  # - time  {Integer} TTL of token
  # - prime {Integer} bits number for SRP
  #
  def initialize(token, time, prime)
    @token = token
    @time  = time
    @prime = prime
  end

  ##
  # Private: fetch user from DB
  #
  # Returns: {Hash} with user params
  #
  def fetch_user_params
    @user = DB[:users].where(login: @login).first
  end

  ##
  # Private: generate challenge for client
  #
  # Returns: {Response} with challenge
  #
  def generate_challenge
    srp     = ::SRP::Verifier.new(@prime)
    session = srp.get_challenge_and_proof(@login, @user[:verifier], @user[:salt], @big_a)
    @proof  = session[:proof].freeze

    overwrite_response(session[:challenge])
  end

  ##
  # Private: match secrets from server and client
  #
  # Returns: {Response} if true: response with cookie, if fail: 401 status
  #
  def match_secrets
    srp = ::SRP::Verifier.new(@prime)
    key_match = srp.verify_session(@proof, @match)

    if key_match
      @big_k = srp.K
      auth_token = @token.generate_and_store(@user, @time, @big_k)
      overwrite_response(key_match: key_match, auth_token: auth_token)
    else
      auth_fail
    end
  end

  ##
  # Private: make response with current data
  #
  # Params:
  # - data {Hash} data for response
  #
  # Returns: {Response} with data
  #
  def overwrite_response(data)
    @response = Rack::Response.new(JSON.unparse(data), 200, 'Content-Type' => 'application/json')
    @response.set_cookie(:session_token, value: data[:auth_token], path: '/') if data[:auth_token]
    @response.finish
  end

  ##
  # Private: make response when auth fail
  #
  # Returns: {Response} with status 401
  #
  def auth_fail
    @response = Rack::Response.new('Email and password do not match', 401)
    @response.finish
  end

end
