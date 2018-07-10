require 'stack-profile'

require 'bogo-config'
require 'sfn'

module Sfn
  class Callback
    class StackProfileCallback < Callback

      def key_allowed?(values, key)
        if values.include?(key) || key.nil?
          return true
        else
          return false
        end
      end

      def allowed_values(context)
        [:environment, :role, :version].each do |key|
          allowed = config.fetch(:stack_profile, :allowed_values, key, nil)
          if allowed
            unless key_allowed?(allowed, context[key])
              raise "Profile Validation Failed: #{context[key]} is not an allowed #{key}."
            end
          end
        end
      end

      def load_profile(profile, context)

        allowed_values(context)

        path = config.fetch(:stack_profile, :profile_directory, '.')
        profile_data = Bogo::Config.new("#{path}/#{profile}.yml").data
        profile_keys = profile_data.keys.select { |key| key != 'meta' and key != 'profile' }

        ## To-Do: Confirm that context keys exist in profile keys

        data = profile_data['default']
        context.each do |key, value|
          next if value.nil?
          if profile_data.keys.include? value
            data = data.merge(profile_data[value])
          else
            warn "Key #{value} not found in profile."
          end
        end
        environment_parameters = profile_data.delete(:environment_parameters) || []
        role_parameters = profile_data.delete(:role_parameters) || []
        version_parameters = profile_data.delete(:version_parameters) || []

        ## Set Stack Tags
        ## Default tags may be overridden
        default_tags = {}
        default_tags[:profile] = profile
        default_tags[:environment] = context[:environment] if context[:environment]
        default_tags[:role] = context[:role] if context[:role]
        default_tags[:version] = context[:version] if context[:version]
        ## Meta tags always override
        meta_tags = {}
        meta_tags[:ttl_days] = config[:ttl] || profile_data[:meta][:default_ttl]
        meta_tags[:rotate_count] = profile_data[:meta][:rotate_count]
        meta_tags[:rotate_wait_seconds] = profile_data[:meta][:rotate_wait_seconds]
        ## Merge tags (Default, Configured, Auto)
        config[:options][:tags] = default_tags.merge(data.delete(:tags)).merge(meta_tags)

        ## Merge Configs
        config[:compile_parameters] = data.delete(:compile_parameters).merge(config[:compile_parameters])
        config[:parameters] = data.delete(:parameters).merge(config[:parameters])
        config[:file] = data.delete(:template)
        config[:apply_stack] = config[:apply_stack].concat(data.delete(:apply_stacks)).uniq

        environment_parameters.each do |param|
          config[:parameters].merge!({ param => context[:environment] })
        end
        role_parameters.each do |param|
          config[:parameters].merge!({ param => context[:role] })
        end
        version_parameters.each do |param|
          config[:parameters].merge!({ param => context[:version] })
        end
      end

      def after_config_update(*_)
        if config[:profile]
          config[:parameters] ||= Smash.new
          config[:compile_parameters] ||= Smash.new
          config[:apply_stack] ||= []
          config[:apply_mapping] ||= Smash.new
          config[:options][:tags] ||= Smash.new
          profile = config[:profile]
          context = {
            environment: config[:environment],
            role: config[:role],
            version: config[:version]
          }
          load_profile(profile, context)
          nil
        end
      end
      alias_method :after_config_create, :after_config_update
      alias_method :after_config_validate, :after_config_update
      alias_method :after_config_print, :after_config_update
    end
  end
end
