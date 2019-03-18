--init
local outVMD='VMD/OutBound.vmd'  --< change vmd name

-- build segment xxx
local function Buidlxxx(inMsg,outMsg)

end


--main function
local function BuildMsg(InBoundMsg,MsgType)
   local OutBoundMsg = hl7.message{vmd=outVMD,name=MsgType}  --change: the vmd file 
	
	-- Create one BuildXXX per Segment
   Buidlxxx(InBoundMsg,OutBoundMsg)
   -- .
   -- .
   -- end of build message

   queue.push{data=OutBoundMsg:S()} --< send message to down stream
end

return BuildMsg