local status = require 'iguana_status'

function main()

   -- Get the Iguana configuration information
   local IguanaConfiguration = status.getIguanaConfiguration()

   -- Get the email notification rules
   local emailNotificationRules = status.getEmailConfigurationRules(IguanaConfiguration)

   -- Get the channel groupings
   local channelGroups = status.getChannelGroups(IguanaConfiguration)

   -- Get the user groupings
   local userGroups = status.getUserGroups(IguanaConfiguration)

   -- Get users
   local users = status.getUsers(IguanaConfiguration)

   local triggered = {}
   for i=1, #emailNotificationRules do 
      -- Get the channels for the email notification rule
      for j=1, #channelGroups[emailNotificationRules[i][1]] do 
         local channelName = channelGroups[emailNotificationRules[i][1]][j]
         -- Check if too much queued messages
         if status.isOverQueued(channelName) then
            table.insert(triggered, channelName)
         end
      end
   end
   
   trace(triggered)

end   