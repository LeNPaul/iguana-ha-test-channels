require 'pepperfish'

profiler = newProfiler('call')
profiler:start()

-- Init
local Filter=require('mdacc.hl7.filter_msg')()
local Build=require('mdacc.hl7.construct_msg')()
local inVMD='VMD/demo.vmd'  --< change vmd name

function main(Data)

   -- Parse inbound message
   local InBoundMsg, MessageType = hl7.parse{vmd=inVMD,data=Data}  --change: the vmd file
   if (MessageType~='IgnoredMessage') then
      -- Filter
      trace(Filter[MessageType](InBoundMsg))
      if (not Filter[MessageType](InBoundMsg)) then
         -- Construct Message
         -- All transform and queue.push will be preform by the function
         Build[MessageType](InBoundMsg,MessageType)
      else
         trace('Message Filtered:'..Data)
      end
   else
      trace('Message Ignored:'..Data)
   end
   
end

profiler:stop()

local outfile = io.open( "/Users/paul.le/Desktop/profile.txt", "w+" )
profiler:report( outfile )
outfile:close()