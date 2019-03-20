--init
local filters={}

--filters

function filters.noGarys(hl7)
   if hl7.PID[5][1][2]:nodeValue() == 'Gary' then
      return true
   end
end

function filters.noMales(hl7)
   if hl7.PID[8]:nodeValue() == 'M' then 
      return true
   end 
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