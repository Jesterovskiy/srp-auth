$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib/srp'))

require 'warden'
require 'warden-srp'
require 'rack'
require 'faker'
require 'rspec'

require 'fakeredis'
REDIS = Redis.new
