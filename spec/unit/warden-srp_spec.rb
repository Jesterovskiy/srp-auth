require 'spec_helper'

describe Warden::SRP::Strategy do
  before do
    app = lambda do |env|
      env['warden'].authenticate!
      Rack::Response.new("OK").finish
    end

    fail_app = lambda do |env|
      Rack::Response.new("FAIL").finish
    end

    @app = Rack::Builder.new do
      use Rack::Session::Cookie
      use Warden::Manager do |manager|
        manager.default_strategies :srp
        manager.failure_app = fail_app
      end

      run app
    end
  end

  let(:user)       { Fixtures[:user].create }
  let(:token)      { Faker::Number.hexadecimal(32).to_s }
  let(:cookie)     { 'session_token=' + token }
  let(:env)        { Rack::MockRequest.env_for('/auth/session', 'HTTP_COOKIE' => cookie) }
  let(:warden_srp) { described_class.new(env) }

  let(:set_redis) { REDIS.set(token, user.to_json) }


  after(:each) do
    REDIS.del(token)
  end

  describe '#valid?' do
    let(:result) { warden_srp.valid? }

    context 'when session is exist' do
      it 'returns token' do
        set_redis
        expect(result).to eq(token)
      end
    end
  end

  describe '#authenticate!' do
    let!(:valid) { warden_srp.valid? }
    let(:result) { warden_srp.authenticate! }

    context 'when session is exist' do
      it 'returns success' do
        set_redis
        expect(result).to eq(:success)
      end
    end

    context 'when session doesn`t exist' do
      it 'returns failure' do
        expect(result).to eq(:failure)
      end
    end
  end

  describe '#user' do
    let!(:valid)       { warden_srp.valid? }
    let(:authenticate) { warden_srp.authenticate! }
    let(:result)       { warden_srp.user }

    context 'when session is exist' do
      it 'returns current user' do
        set_redis
        authenticate
        expect(result).to eq(JSON.load(user.to_json))
      end
    end

    context 'when session doesn`t exist' do
      it 'returns nil' do
        expect(result).to be nil
      end
    end
  end
end
