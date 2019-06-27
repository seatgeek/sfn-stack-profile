require 'stack-profile'
require 'stack-profile/builder'

RSpec.describe StackProfile::Builder do
  config = {
    stack_profile: {
      profile_directory: 'spec'
    }
  }

  context = {
    environment: 'env_1',
    role: 'role'
  }

  # Expected Outputs
  env_1_role_no_defaults = {
    'apply_stack' => [
      'env1_vpc'
    ],
    'compile_parameters' => {
      'availability_zones' => 4,
      'environment' => 'env_1',
    },
    'parameters' => {
      'environment' => 'env_1',
      'class' => 'role',
      'service' => 'role',
      'tld' => 'env1',
      'max_instances' => 5
    },
    options: {
      'tags' => {
        'rotate_count' => 1,
        'rotate_wait_seconds' => 300,
        'ttl_days' => 7,
        'profile' => 'no_default_profile',
        'environment' => 'env_1',
        'role' => 'role'
      }
    },
  }

  profile = StackProfile::Builder.new(config)

  context "With a Profile" do
    it "has config" do
      expect(profile.load_profile('no_default_profile')).not_to include(:default)
      expect(profile.load_profile('no_default_profile')).to include(:profile)
      expect(profile.load_profile('no_default_profile')).to include(:meta)
    end
  end

  context "With Only Environment Overrides" do
    data = profile.profile_config('no_default_profile', context)

    it "Merges Compile Time Parameters" do
      expect(data[:compile_parameters]).to eq(env_1_role_no_defaults['compile_parameters'])
    end

    it "Merges Parameters" do
      expect(data[:parameters]).to eq(env_1_role_no_defaults['parameters'])
    end

    it "Applies a stack" do
      expect(data[:apply_stacks]).to eq(env_1_role_no_defaults['apply_stacks'])
    end

    it "Sets Stack Tags" do
      expect(data[:options][:tags]).to eq(env_1_role_no_defaults[:options]['tags'])
    end
  end
end
