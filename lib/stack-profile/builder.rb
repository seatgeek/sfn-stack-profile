require 'stack-profile'

module StackProfile
  class Builder

    def initialize(config = {})
      @config = config
    end

    def load_profile(profile)
      path = @config[:stack_profile].fetch(:profile_directory, '.')
      profile_data = Bogo::Config.new("#{path}/#{profile}.yml").data
      return profile_data
    end

    def key_allowed?(values, key)
      if values.include?(key) || key.nil?
        return true
      else
        return false
      end
    end

    def update_allowed?(profile)
      profile_data = load_profile(profile)
      if profile_data['meta']['updates_allowed']
        return true
      else
        return false
      end
    end

    def allowed_values(context)
      if @config[:stack_profile][:allowed_values]
        [:environment, :role, :version].each do |key|
          allowed = @config[:stack_profile][:allowed_values].fetch(key, nil)
          if allowed
            unless key_allowed?(allowed, context[key])
              raise "Profile Validation Failed: #{context[key]} is not an allowed #{key}."
            end
          end
        end
      end
    end

    def profile_config(profile, context, stack_name=nil)
      profile_data = load_profile(profile)

      profile_keys = profile_data.keys.select { |key| key != 'meta' and key != 'profile' }

      allowed_values(context)

      ## To-Do: Confirm that context keys exist in profile keys

      data = profile_data[:default] || {}

      context.each do |key, value|
        next if value.nil?
        if profile_keys.include? value
          profile_data[value].keys.each do |k|
            ## Merge hashes, override arrays & strings
            if data[k].is_a? Hash
              data[k] = data[k].merge(profile_data[value][k])
            elsif data[k].is_a? Array
              data[k] = data[k] +=  profile_data[value][k]
            else
              data[k] = profile_data[value][k]
            end
          end
#          ui.info "Merged #{key.capitalize} #{value} into configuration."
        else
#          ui.info "#{key.capitalize} #{value} is not defined in #{profile}, will only be applied to tags and parameters."
        end
      end

      environment_compile_parameters = profile_data.delete(:environment_compile_parameters) || []
      role_compile_parameters = profile_data.delete(:role_compile_parameters) || []
      version_compile_parameters = profile_data.delete(:version_compile_parameters) || []
      environment_parameters = profile_data.delete(:environment_parameters) || []
      role_parameters = profile_data.delete(:role_parameters) || []
      version_parameters = profile_data.delete(:version_parameters) || []

      ## Set Stack Tags
      ## Default tags may be overridden
      unless @config[:options]
        @config[:options] = {}
      end
      default_tags = @config[:options][:tags] || {}
      default_tags['profile'] = profile
      default_tags['environment'] = context[:environment]# if context[:environment]
      default_tags['role'] = context[:role]# if context[:role]
      default_tags['version'] = context[:version]# if context[:version]
      ## Meta tags always override
      meta_tags = {}
      meta_tags['ttl_days'] = @config[:ttl] || profile_data[:meta][:default_ttl]
      meta_tags['rotate_count'] = profile_data[:meta][:rotate_count]
      meta_tags['rotate_wait_seconds'] = profile_data[:meta][:rotate_wait_seconds]

      ## Merge tags (Default, Configured, Auto)
      @config[:options][:tags] ||= {}
      profile_tags = data.delete('tags') || {}
      @config[:options][:tags] = default_tags.merge(profile_tags).merge(meta_tags)

      ## Merge Configs
      profile_compile_parameters = data.delete('compile_parameters') || {}
      @config[:compile_parameters] ||= {}
      @config[:compile_parameters] = profile_compile_parameters.merge(@config[:compile_parameters])

      profile_parameters = data.delete('parameters') || {}
      @config[:parameters] ||= {}
      @config[:parameters] = profile_parameters.merge(@config[:parameters])

      # ## Template logic for updates/change sets
      # if stack_name
      #   unless profile_data[:meta][:template_update_allowed]
      #     config[:file] = nil
      #   end
      #   if profile_data[:meta][:always_update_template]
      #     config[:file] = config[:file] || data.delete(:template)
      #   end
      #   data.delete(:template)
      # else
      #   config[:file] = data.delete(:template)
      # end

      if data[:apply_stacks]
        @config[:apply_stack] ||= []
        @config[:apply_stack] = @config[:apply_stack].concat(data.delete(:apply_stacks)).uniq
      end

      if data[:mappings]
        @config[:mappings] ||= {}
        @config[:apply_mapping] = @config[:apply_mapping].merge(data.delete(:mappings))
      end

      ## Merge mapped parameters
      environment_compile_parameters.each do |param|
        if context[:environment]
          @config[:compile_parameters].merge!({ param => context[:environment] })
        end
      end
      role_compile_parameters.each do |param|
        if context[:role]
          @config[:compile_parameters].merge!({ param => context[:role] })
        end
      end
      version_compile_parameters.each do |param|
        if context[:version]
          @config[:compile_parameters].merge!({ param => context[:version] })
        end
      end
      environment_parameters.each do |param|
        if context[:environment]
          @config[:parameters].merge!({ param => context[:environment] })
        end
      end
      role_parameters.each do |param|
        if context[:role]
          @config[:parameters].merge!({ param => context[:role] })
        end
      end
      version_parameters.each do |param|
        if context[:version]
          @config[:parameters].merge!({ param => context[:version] })
        end
      end

      if @config[:compile_parameters]
        @config[:compile_parameters] = @config[:compile_parameters].reject { |k,v| v.nil? }
      end

      if @config[:parameters]
        @config[:parameters] = @config[:parameters].reject { |k,v| v.nil? }
      end

      if @config[:mappings]
        @config[:mappings] = @config[:mappings].reject { |k,v| v.nil? }
      end

      if @config[:options][:tags]
        @config[:options][:tags] = @config[:options][:tags].reject { |k,v| v.nil? }
      end

      return @config
    end
  end
end
