--init
local filters={}

--filters

function filters.xxx(hl7)

     return false
end

--main function
local function IsFilter(InBoundMsg)
   local filter=false
   for k,v in pairs(filters) do  --< call each filter function
      success=v(InBoundMsg)
      if (success) then  --< exit as soon as one return true
         filter=true
         break
      end
   end
   return filter
end

return IsFilter