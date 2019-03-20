-- The main function is the first function called from Iguana.
local me = {appID='template_batch_validate'}

--load modules

local mda_config = require 'mdacc.config'
local validate = require 'validation'

--local variables
local config = nil
local batch = nil

function main(Data)
   local fileList = batch:list(config.source.path,config.source.files)
   local errors=validate(config.source.path,fileList,config.source.files)
      if (#errors > 0 ) then
      local txt='Validation Errors:\n'
      for i=1,#errors do
         txt=txt..'\t'..errors[i]..'\n'
      end
      iguana.logWarning(txt)
   end
   queue.push(config.source.path)  -- push to next channel
end

function main_init()  -- load config 
   config = mda_config.loadConfig(me.appID)
   config._configRoot=  os.getenv("mda_appconfig")..'/'..me.appID..'/'
   batch= require('mdacc.batch.transport.base')('fs',nil,config.retry)
end

main_init()
