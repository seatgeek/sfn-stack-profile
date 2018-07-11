require 'stack-profile'
require 'sfn'

module Sfn
 class Config
   class Validate
      attribute(
        :profile, String,
        :description => 'Stack Profile'
      )
      attribute(
        :environment, String,
        :description => 'Profile Environment'
      )
      attribute(
        :role, String,
        :description => 'Profile Role'
      )
      attribute(
        :version, String,
        :description => 'Stack Version'
      )
   end
   class Create
     attribute(
       :profile, String,
       :description => 'Stack Profile'
     )
     attribute(
       :environment, String,
       :description => 'Profile Environment'
     )
     attribute(
       :role, String,
       :description => 'Profile Role'
     )
     attribute(
       :ttl, String,
       :description => 'Stack TTL'
     )
     attribute(
       :version, String,
       :description => 'Stack Version'
     )
   end
   ## Update and Change Sets don't work yet
   class Update
     attribute(
       :profile, String,
       :description => 'Stack Profile'
     )
     attribute(
       :environment, String,
       :description => 'Profile Environment'
     )
     attribute(
       :role, String,
       :description => 'Profile Role'
     )
     attribute(
       :ttl, String,
       :description => 'Stack TTL'
     )
     attribute(
       :version, String,
       :description => 'Stack Version'
     )
   end
   class ChangeSet
     attribute(
       :profile, String,
       :description => 'Stack Profile'
     )
     attribute(
       :environment, String,
       :description => 'Profile Environment'
     )
     attribute(
       :role, String,
       :description => 'Profile Role'
     )
     attribute(
       :ttl, String,
       :description => 'Stack TTL'
     )
     attribute(
       :version, String,
       :description => 'Stack Version'
     )
   end
 end
end
