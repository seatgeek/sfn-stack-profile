require 'stack-profile'
#require 'stack-profile/profile'
require 'stack-profile/builder'

RSpec.describe StackProfile::Builder do
  config = {
    stack_profile: {
      profile_directory: 'spec'
    }
  }

  context = {
    environment: 'env_1',
    role: 'role',
    version: 'v0.0.0'
  }

  # Expected Outputs
  env1_output = {
    'apply_stack' => [
      'env1_vpc'
    ],
    'compile_parameters' => {
      'subnet_zone' => 'private',
      'availability_zones' => 4,
      'environment' => 'env_1'
    },
    'parameters' => {
      'instance_type' => 'm4.4xlarge',
      'service' => 'default-service',
      'min_instances' => 3,
      'max_instances' => 5,
      'environment' => 'env_1',
      'tld' => 'env1',
      'class' => 'role',
      'service' => 'role',
      'version' => 'v0.0.0'
    },
    'template' => 'default_template',
    options: {
      'tags' => {
        'team' => 'testers',
        'rotate_count' => 1,
        'rotate_wait_seconds' => 300,
        'ttl_days' => 7,
        'profile' => 'spec_profile',
        'environment' => 'env_1',
        'role' => 'role',
        'version' => 'v0.0.0'
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

  context "With Allowed Keys" do
  end

  context "Without Allowed Keys" do
  end

  context "With Environment, Role, & Version Overrides" do
    data = profile.profile_config('spec_profile', context)

    it "Merges Compile Time Parameters" do
      expect(data[:compile_parameters]).to eq(env1_output['compile_parameters'])
    end

    it "Merges Parameters" do
      expect(data[:parameters]).to eq(env1_output['parameters'])
    end

    it "Applies a Stack" do
      expect(data[:apply_stacks]).to eq(env1_output['apply_stacks'])
    end

    it "Sets Stack Tags" do
      expect(data[:options][:tags]).to eq(env1_output[:options]['tags'])
    end
  end
end
