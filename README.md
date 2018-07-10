## About this Callback
This is an `sfn` [callback]() that adds support for defining Cloudformation Stacks via a profile that describes the default settings for one or more similar stacks. It is similar to the sfn-parameters callback, but more flexible because profiles have a one-to-many relationship to stacks.

Stack profiles are yaml files that define a set of defaults and one or more contexts that may extend or override the defaults as the environment, role, and/or version of a stack.

## Usage
The callback adds 5 additional flags to the `print`, `validate`, `create`, and `update` commands:
* `--profile`: The name of the profile (filename with the extension omitted)
* `--environment` (optional): The name of a context in the profile that represents the stack environment
* `--role` (optional): The name of a context in the profile that represents the stack role
* `--version` (optional): The name of a context in the profile that represents the stack version
* `--ttl` (optional): specify the Time To Live (in days) for a stack.

The command:
```
sfn create my-stack --profile nomad-stack --environment production --role applications --version 2.0.2 --ttl 30
```
would create a new stack using the `nomad-stack` profile, with the `production`, `applications`, and `2.0.2` contexts and a `ttl` of 30 days.

## Configuration
The callback is configured via the `.sfn` config file. There are a few options:
```ruby
Configuration.new do
  callbacks do
    require ['stack-profile']
    default ['stack_profile_callback']
  end
  stack_profile do
    profile_directory 'profiles'
    allowed_values do
      environment [
        'management',
        'performance',
        'production',
        'qa',
        'staging'
      ]
      role [
        'applications',
        'high-cpu-applications',
        'profile'
      ]
      version []
    end
  end
end
```
To enable the callback, add it to the Gemfile, then add `stack-profile` to the `require` array add `stack_profile_callback` to the `default` array in the `callbacks` config block.
In a `stack_profile` block, configure the `profile_directory` that contains profile files, and any value restrictions for `environment`, `role`, or `version` under the `allowed_values` block.

### Allowed Values
For each context (`environment`, `role`, `version`) you may limit the set of allowed values. This allows you to configure a specific set of environments, roles, or versions at a project level. If these are omitted, or left empty, then any value will be allowed for that context. Settings in the profile are always applied in the order `default`, `environment`, `role`, `version`.
With the above settings, `create my stack --profile nomad-stack --environment production --role applications` is valid, but `create my stack --profile nomad-stack --environment applications --role profile` is not.

## Profiles
Profiles are a YAML file. The profile name should match the filename. A basic profile:
```yaml
profile: nomad-stack

# Parameter mappings
environment_parameters:
  - environment

role_parameters:
  - class
  - service

version_parameters:
  - ami_version

# Default Settings
default:
  template: core_service
  compile_parameters:
    subnet_zone: private
    availability_zones: 3
  parameters:
    instance_type: m4.4xlarge
    environment: performance
    ebs_size: 200
  tags:
    cost_center: infra

# Environment Contexts
production:
  apply_stacks:
    - production-vpc
    - production-internal-alb

staging:
  apply_stacks:
    - staging-vpc

# Role Contexts
applications:
  parameters:
    instance_type: m4.4xlarge

high-cpu-applications:
  parameters:
    instance_type: c4.4xlarge

meta:
  default_ttl: 7
  rotate_count: 1
  rotate_wait_seconds: 300
  notify_slack_channels: infrastructure,ops-messages,dev,nro
  updates_allowed: true
  template_update_allowed: true
  always_update_template: false
```
