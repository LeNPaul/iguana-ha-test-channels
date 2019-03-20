local date = require 'interfaceware.date.parse'
local time_util={}

function time_util.timeStamp(f)
   if (f==nil) then
      f='%Y%m%d%H%M%S'
   end
	return os.ts.date(f)
end

function time_util.time(s,f)
	local d=date.parse(s)
   return os.date(f,d):upper()
end

return time_util