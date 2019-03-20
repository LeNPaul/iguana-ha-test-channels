--http://localhost:6543/mapper/- The main function is the first function called from Iguana.
-- The Data argument will contain the message to be processed.
-- zero is ok.  none zero is bad
local me = {appID='template_batch_archive'}

--local modules
local time=require('mdacc.time_util')
local mda_config=require('mdacc.config')

--local variables
local config=nil
local batch=nil

function main(Data)
	local fname=config.archive.path..config.archive.filePrefix..time.timeStamp()
   batch:archive(config.source.path,fname)
   queue.push(config.source.path) -- push something to next channel
end


function main_init()  -- load config      
   config = mda_config.loadConfig(me.appID)
   config._configRoot=  os.getenv("mda_appconfig")..'/'..me.appID..'/'
   batch= require('mdacc.batch.transport.base')('fs',nil,config.retry)
end

main_init()