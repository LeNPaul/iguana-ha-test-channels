local file = require 'fileUtil'
local config = require 'config'

local status = {}

function status.isOverQueued(channelName) 
   local iguanaStatus = xml.parse{data=iguana.status()}
   local triggeredChannels = {}
   for i=1, iguanaStatus.IguanaStatus:childCount("Channel") do 
      if iguanaStatus.IguanaStatus:child("Channel", i).Name:nodeValue() == channelName then 
         local queueCount = iguanaStatus.IguanaStatus:child("Channel", i).MessagesQueued:nodeValue()
         if tonumber(queueCount) > config.queueThreshold then
            -- Log a warning message to trigger an email notification
            return true
         end
      end
   end
   return false
end

function status.getIguanaConfiguration() 
   local IguanaConfigurationPath = iguana.appDir()..'IguanaConfigurationRepo/IguanaConfiguration.xml'
   local IguanaConfiguration = xml.parse{data=file.readFile(IguanaConfigurationPath)}
   return IguanaConfiguration
end

function status.getChannelGroups(IguanaConfiguration) 
   local channelGroups = {}
   for i=1, IguanaConfiguration.iguana_config.channel_groupings:childCount("grouping") do 
      local groups = IguanaConfiguration.iguana_config.channel_groupings:child("grouping", i)
      local groupName = groups.grouping_name:nodeValue()
      local channels = {}
      for j=1, groups.channels:childCount("channel") do 
         table.insert(channels, groups.channels:child("channel", j).channel_name:nodeValue())
      end
      channelGroups[groupName] = channels
   end
   return channelGroups
end

function status.getUserGroups(IguanaConfiguration) 
   local userGroups = {}
   for i=1, IguanaConfiguration.iguana_config.auth_config:childCount("group") do 
      table.insert(userGroups, IguanaConfiguration.iguana_config.auth_config:child("group", i).name:nodeValue())      
   end
   return userGroups
end

function status.getUsers(IguanaConfiguration) 
   local users = {}
   for i=1, IguanaConfiguration.iguana_config.auth_config:childCount("user") do 
      table.insert(users, {
            IguanaConfiguration.iguana_config.auth_config:child("user", i).name:nodeValue(),
            IguanaConfiguration.iguana_config.auth_config:child("user", i).email_address:nodeValue()
         })
   end
   return users
end

function status.getEmailConfigurationRules(IguanaConfiguration) 
   local emailNotificationRules = {}
   for i=1, IguanaConfiguration.iguana_config.email_config:childCount("standard_email_notification_rule") do 
      if IguanaConfiguration.iguana_config.email_config:child("standard_email_notification_rule", i).source_type:nodeValue() == '3' then
         local emailNotificationRule = IguanaConfiguration.iguana_config.email_config:child("standard_email_notification_rule", i)
         local emailRecipients = {}
         for j=1, emailNotificationRule:childCount("email_recipient") do 
            table.insert(emailRecipients, emailNotificationRule:child("email_recipient", j).email_rule_recipient:nodeValue())
         end
         table.insert(emailNotificationRules, {emailNotificationRule.source_name:nodeValue(), emailRecipients})
      end
   end
   return emailNotificationRules
end

return status