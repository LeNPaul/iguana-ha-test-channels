local crontab={}

local rangeTable =  {min={0,59},
   hour={0,23},
   day={0,31},
   month={0,12},
   wday={0,6}
}

local function check(entry,value)
   local flag = false
   local entries=entry:split(',')
   for i=1,#entries do
      local range=entries[i]:split("-")
      if #range == 2 then   -- Must be range
         if (tonumber(range[1]) <= value and tonumber(range[2]) >=value) then
            flag=true
         end
      else   -- single value
         if (entries[i]=="*") then
            flag=true
         else
            if (tonumber(entries[i]) == value) then
               flag=true
            end
         end
      end
   end
   return flag
end

local function checkRange(entry,value)
   local entries=entry:split(',')
   trace(#entries)
   for i=1,#entries do
      local range=entries[i]:split("-")
      if #range == 2 then   -- Must be range 
         if (tonumber(range[1]) ~=nil and tonumber(range[2]) ~=nil) then
            if (tonumber(range[1]) >= tonumber(range[2])) then
               return false
            end
            for i=1,2 do
               if (tonumber(range[i]) < value[1] or tonumber(range[i]) >value[2]) then
                  return false
               end
            end
         else
            return false
         end
      else   -- single value
         if (tonumber(entries[i])==nil and entries[i]~="*") then
            return false
         else
            if (tonumber(entries[1]) ~= nil) then
               if (tonumber(entries[i]) < value[1] and tonumber(entries[i]) > value[2]) then
                  return false
               end
            end
         end
      end
   end
   return true
end

function crontab.canRun(cronEntry,now)
	local subFields = cronEntry:split(" ") 
   local table = {min=subFields[1],
                  hour=subFields[2],
                  day=subFields[3],
                  month=subFields[4],
                  wday=subFields[5]
   }
   if (check(table.min,now.min)==false) then 
      return false
   end
   if (check(table.hour,now.hour)==false) then 
      return false
   end
   if (check(table.day,now.day)==false) then 
      return false
   end
   if (check(table.month,now.month)==false) then 
      return false
   end
   -- os date is 1=Sunday while cron 0=Sunday
   if (check(table.wday,now.wday-1)==false) then 
      return false
   end   
	return true
end

function crontab.isValid(cronEntry)
   local subFields = cronEntry:split(" ") 
   if (#subFields ~= 5) then
      iguana.logError("Invalid Cron Entry: There should be only 5 subfield:\n"..json.serialize{data=subFields})
      return false
   end
   local table = {min=subFields[1],
      hour=subFields[2],
      day=subFields[3],
      month=subFields[4],
      wday=subFields[5]
   }
   for k,v in pairs(table) do
      if (not checkRange(v,rangeTable[k])) then 
         iguana.logError("Invalid Cron Entry: SubField "..k.." is invalid:"..v.." should be between "..rangeTable[k][1].." to "..rangeTable[k][2])
         return false
      end
   end
   return true
end

return crontab