##
# Class: generate and store token in Redis
#
class Auth::Token
  ##
  # Public: token generation and store in Redis
  #
  # Params:
  #   - user {User} user params
  #   - time {Integer} TTL of token
  #   - k    {String} strong key for sing
  #
  # Returns: {String} with token
  #
  def generate_and_store(user, time, k)
    token = generate_auth_token(k)
    REDIS.setex(token, time, JSON.generate(user))
    token
  end

private

  ##
  # Private: generate auth token
  #
  # Params:
  # - k {String} strong key for sing
  #
  # Returns: {String} with JWS token
  #
  def generate_auth_token(k)
    claim = {
      exp: 1.week.from_now,
      nbf: Time.now
    }

    jwt = JSON::JWT.new(claim)
    jws = jwt.sign(k)
    jws.to_s
  end

end
