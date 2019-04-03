require 'stack-profile'
require 'sfn'

module Sfn
 class Config
   class Validate
      attribute(
        :profile, String,
        :description => 'Stack Profile',
        :default => ENV['PROFILE']
      )
      attribute(
        :environment, String,
        :description => 'Profile Environment',
        :default => ENV['ENVIRONMENT']
      )
      attribute(
        :role, String,
        :description => 'Profile Role',
        :default => ENV['ROLE']
      )
      attribute(
        :version, String,
        :description => 'Stack Version',
        :default => ENV['VERSION']
      )
      attribute(
        :defaults, [TrueClass, FalseClass],
        :default => ENV['DEFAULTS'] == 'true' ? true : false
      )
   end
   class Create
     attribute(
       :profile, String,
       :description => 'Stack Profile',
       :default => ENV['PROFILE']
     )
     attribute(
       :environment, String,
       :description => 'Profile Environment',
       :default => ENV['ENVIRONMENT']
     )
     attribute(
       :role, String,
       :description => 'Profile Role',
       :default => ENV['ROLE']
     )
     attribute(
       :version, String,
       :description => 'Stack Version',
       :default => ENV['VERSION']
     )
     attribute(
       :ttl, String,
       :description => 'Stack TTL',
       :default => ENV['TTL']
     )
     attribute(
       :defaults, [TrueClass, FalseClass],
       :default => ENV['DEFAULTS'] == 'true' ? true : false
     )
   end
   class Update
     attribute(
       :profile, String,
       :description => 'Stack Profile',
       :default => ENV['PROFILE']
     )
     attribute(
       :environment, String,
       :description => 'Profile Environment',
       :default => ENV['ENVIRONMENT']
     )
     attribute(
       :role, String,
       :description => 'Profile Role',
       :default => ENV['ROLE']
     )
     attribute(
       :version, String,
       :description => 'Stack Version',
       :default => ENV['VERSION']
     )
     attribute(
       :ttl, String,
       :description => 'Stack TTL',
       :default => ENV['TTL']
     )
     attribute(
       :defaults, [TrueClass, FalseClass],
       :default => ENV['DEFAULTS'] == 'true' ? true : false
     )
   end
   class ChangeSet
     attribute(
       :profile, String,
       :description => 'Stack Profile',
       :default => ENV['PROFILE']
     )
     attribute(
       :environment, String,
       :description => 'Profile Environment',
       :default => ENV['ENVIRONMENT']
     )
     attribute(
       :role, String,
       :description => 'Profile Role',
       :default => ENV['ROLE']
     )
     attribute(
       :version, String,
       :description => 'Stack Version',
       :default => ENV['VERSION']
     )
     attribute(
       :ttl, String,
       :description => 'Stack TTL',
       :default => ENV['TTL']
     )
     attribute(
       :defaults, [TrueClass, FalseClass],
       :default => ENV['DEFAULTS'] == 'true' ? true : false
     )
   end
 end
end
