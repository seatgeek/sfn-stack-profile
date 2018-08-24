require 'bogo-config'
require 'sfn'

require 'stack-profile'

RSpec.describe Sfn::Callback::StackProfileCallback do

  context = {
    stack_profile: {
      profile_directory: 'spec',
      allowed_values: {}
    },
    environment: 'env1',
    role: 'role',
    version: 'v0.0.0'
  }

  profile = Sfn::Callback::StackProfileCallback.new('profile_spec', context, 'test-stack', true)

  profile.profile_config('profile_spec', context, 'test-stack')
  # profile.profile_config

  puts profile
  it "has config" do
    expect profile.to include(:parameters)
  end
end
