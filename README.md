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
environment_compile_parameters:
  - environment

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
About each section:
#### Parameter Mappings
Each context argument (`environment`, `role`, `version`) can be mapped to one or more compile time or run time parameters automatically. In this example, we're mapping the `environment` value to the `environment` compile time and run time parameters; the `role` value to both the `service` and `class` parameters; and the `version` value to the `ami_version` parameter. Each of the context arguments are included in the stack tags, so even though we haven't defined any version context, the version argument is a useful way to pass in both a parameter value and add metadata to the stack and resources.

#### Default Settings & Contexts
The `default` and context hashes accept the following keys:
* `template` (string): The name of the Sparkleformation template to use for this stack.
* `compile_parameters` (hash): Sparkleformation Compile Time Parameters as key-value pairs.
* `parameters` (hash): Cloudformation Parameters as key-value pairs.
* `apply_stacks` (array): A list of stacks whose outputs should be applied as parameter defaults.
* `tags` (hash): A list of tags to apply to the Cloudformation stack, which will be propagated to resources that support tagging.

Contexts are merged on top of the default settings in the order of `environment`, `role`, and `version` (not used here).
In this example, the default settings account for the template, compile time parameters, and sane defaults for some parameters. The Environment contexts are used exclusively for the `apply_stack` arguments to gather environment specific VPC and ALB ids. The Role contexts set distinct instance types based on the workloads that will run in those stacks.

Our example command:
```
sfn create my-stack --profile nomad-stack --environment production --role applications --version 2.0.2 --ttl 30
```
would generate the merged stack config:
```yaml
template: core_service
compile_parameters:
  subnet_zone: private
  availability_zones: 3
  environment: production
parameters:
  environment: production
  service: applications
  class: application
  ami_version: 2.0.2
  instance_type: m4.4xlarge
  environment: performance
  ebs_size: 200
apply_stacks:
  - production-vpc
  - production-internal-alb
tags:
  cost_center: infra
  profile: nomad-client
  environment: production
  role: applications
  version: 2.0.2
  ttl_days: 30
  rotate_count: 1
  rotate_wait_seconds: 300
```
Note that this is very similar to the stack files, with the additional of stack tags.

#### Meta
The `meta` hash includes information about how the profiles callback and other tooling will interact with the stacks.

`default_ttl` is the default TTL, and may be overriden with the `--ttl` flag.

`rotate_count` and `rotate_wait_seconds` are instructions for autoscaling group replacement via an external tool (to be implemented).

`notify_slack_channels` can be used with an external notification service to alert Slack channels during stack updates.

`updates_allowed`, `template_update_allowed`, and `always_update_template` instruct the profile callback about whether to allow a stack update, and if so, whether to update the stack template during an update. Note that these are enforced via the profile callback, so these settings will not prevent updates via other tools.
