require 'stack-profile'
#require 'stack-profile/profile'
require 'stack-profile/builder'

RSpec.describe StackProfile::Builder do
  config = {
    stack_profile: {
      profile_directory: 'spec'
    }
  }

  # Expected Outputs
  default_output = {
    'compile_parameters' => {
      'subnet_zone' => 'private',
      'availability_zones' => 3
    },
    'parameters' => {
      'instance_type' => 'm4.4xlarge',
      'service' => 'default-service',
      'min_instances' => 3,
      'max_instances' => 100,
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

  context "With No Overrides" do
    data = profile.profile_config('spec_profile', {})

    it "Has a default config" do
      expect(profile.load_profile('spec_profile')).to include('default')
    end

    it "Has default compile time parameters" do
      expect(data[:compile_parameters]).to eq(default_output['compile_parameters'])
    end

    it "Has default parameters" do
      expect(data[:parameters]).to eq(default_output['parameters'])
    end

    it "Has Default Stack Tags" do
      expect(data[:options][:tags]).to eq(default_output[:options]['tags'])
    end

    it "Doesn't apply stacks" do
      expect(data[:apply_stack]).to be nil
    end
  end
end
