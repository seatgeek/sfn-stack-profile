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
  }

  # Expected Outputs
  env_1_only_output = {
    'apply_stack' => [
      'env1_vpc'
    ],
    'compile_parameters' => {
      'subnet_zone' => 'private',
      'availability_zones' => 4,
      'environment' => 'env_1',
    },
    'parameters' => {
      'instance_type' => 'm4.4xlarge',
      'service' => 'default-service',
      'min_instances' => 3,
      'max_instances' => 100,
      'environment' => 'env_1',
      'tld' => 'env1'
    },
    'template' => 'default_template',
    options: {
      'tags' => {
        'team' => 'testers',
        'rotate_count' => 1,
        'rotate_wait_seconds' => 300,
        'ttl_days' => 7,
        'profile' => 'spec_profile',
      }
    },
  }

  env_1_role_no_defaults = {
    'apply_stack' => [
      'env1_vpc'
    ],
    'compile_parameters' => {
      'availability_zones' => 4
    },
    'parameters' => {
      'tld' => 'env1'
    },
    options: {
      'tags' => {
        'rotate_count' => 1,
        'rotate_wait_seconds' => 300,
        'ttl_days' => 7,
        'profile' => 'spec_profile',
      }
    },
  }

  profile = StackProfile::Builder.new(config)

  context "With a Profile" do
    it "has config" do
      expect(profile.load_profile('spec_profile')).to include(:default)
      expect(profile.load_profile('spec_profile')).to include(:profile)
      expect(profile.load_profile('spec_profile')).to include(:meta)
    end
  end

  context "With Only Environment Overrides" do
    data = profile.profile_config('spec_profile', context)

    it "Merges Compile Time Parameters" do
      expect(data[:compile_parameters]).to eq(env_1_only_output['compile_parameters'])
    end

    it "Merges Parameters" do
      expect(data[:parameters]).to eq(env_1_only_output['parameters'])
    end

    it "Applies a stack" do
      expect(data[:apply_stacks]).to eq(env_1_only_output['apply_stacks'])
    end
  end
end
