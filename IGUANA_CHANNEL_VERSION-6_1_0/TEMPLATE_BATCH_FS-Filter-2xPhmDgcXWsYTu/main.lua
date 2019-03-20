-- The main function is the first function called from Iguana.
local me = {appID='template_batch_fs_out'}

--load modules
local mda_config = require 'mdacc.config'

--local variable
local config=nil
local batch=nil

function main()  
   local fileList = batch:list(config.source.path,config.source.files)
   batch:copy(config.source.path,config.destination.path,fileList)
-- Only Enable when ready.
--	batch:delete(config.source.path,fileList)
end

function main_init()  -- load config 
   config = mda_config.loadConfig(me.appID)
   config._configRoot=  os.getenv("mda_appconfig")..'/'..me.appID..'/'
   batch= require('mdacc.batch.transport.base')('fs',nil,config.retry)
   trace(config)
end

main_init()