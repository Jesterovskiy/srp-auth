##
# Class: implement SRP protocol
#
class Auth::ResetPassword
  def call(env)
    @token = Rack::Request.new(env).params['reset_password_token']
    env['reset_password_login'] = @token ? fetch_login : false
  end

  ##
  # Public: generate token for reset password
  #
  # Returns: {String} with token
  #
  def self.generate_token
    claim = {
      exp: 1.week.from_now,
      nbf: Time.now
    }

    JSON::JWT.new(claim).to_s
  end

private

  attr_reader :token

  ##
  # Private: get user login by token
  #
  # Returns: {String|Boolean} with login or false
  #
  def fetch_login
    user = DB[:users].where(reset_password_token: @token).first
    user ? user[:login] : false
  end
end
