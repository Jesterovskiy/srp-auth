require_relative 'warden/srp'

Warden::Strategies.add :srp, Warden::SRP::Strategy
