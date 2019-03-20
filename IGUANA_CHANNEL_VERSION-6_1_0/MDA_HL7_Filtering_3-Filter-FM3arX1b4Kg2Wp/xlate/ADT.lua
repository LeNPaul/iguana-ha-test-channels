--init
local outVMD='VMD/demo.vmd'  --< change vmd name

-- build segment MSH
local function BuidlMSH(inMsg,outMsg)

   -- Change some fields
   outMsg.MSH[3][1] = 'Iguana'
   outMsg.MSH[5][1] = 'Also Iguana'
   outMsg.MSH[17] = 'CA'

end


-- build segment PID
local function BuidlPID(inMsg,outMsg)

   -- Change some fields
   outMsg.PID[5][1][2] = 'Paul'
   outMsg.PID[5][1][1][1] = 'Le'
   outMsg.PID[8] = 'M'
   outMsg.PID[12] = 'CA'
   outMsg.PID[6][1][1][1] = 'Nguyen'
   outMsg.PID[13][1][1] = '9054575161'
   outMsg.PID[22][1][1] = 'Vietnamese'
   outMsg.PID[17][1] = 'None'
   outMsg.PID[26][1][1] = 'CA'
   outMsg.PID[23] = 'Canada'

end

-- build segment OBX
local function BuidlOBX(inMsg,outMsg)

   -- Change some fields
   outMsg.OBX[2][5][1][1] = '175'
   outMsg.OBX[1][5][1][1] = '75'

end

--main function
local function BuildMsg(InBoundMsg,MsgType)
   local OutBoundMsg = hl7.message{vmd=outVMD,name=MsgType}  --change: the vmd file 

   -- Map entire message
   OutBoundMsg:mapTree(InBoundMsg)

   -- Create one BuildXXX per Segment
   BuidlMSH(InBoundMsg,OutBoundMsg)
   BuidlPID(InBoundMsg,OutBoundMsg)
   BuidlOBX(InBoundMsg,OutBoundMsg)
   -- .
   -- end of build message

   queue.push{data=OutBoundMsg:S()} --< send message to down stream
end

return BuildMsg