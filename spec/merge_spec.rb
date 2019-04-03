require 'bogo-config'
require 'sfn'

#require 'stack-profile'
#require 'stack-profile/command'
require 'stack-profile/profile'

RSpec.describe Sfn::Callback::StackProfileCallback do
  let(:ui) { double("ui") }
  let(:config) { Smash.new }
  let(:arguments) { [] }

  context = {}
  #   environment: 'env1',
  #   role: 'role',
  #   version: 'v0.0.0'
  # }

  profile = Sfn::Callback::StackProfileCallback.new('profile_spec', context, 'test-stack', true)


  profile.load_config('profile_spec')

  profile.profile_config('profile_spec', context)
  profile.profile_config

  puts profile
  it "has config" do
    expect profile.to include(:parameters)
  end
end
