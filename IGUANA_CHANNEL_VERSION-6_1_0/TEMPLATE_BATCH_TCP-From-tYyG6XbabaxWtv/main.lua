-- The main function is the first function called from Iguana.
local me = {appID='mpog_sftp_set_2_in'}

--load modules
local mda_config = require 'mdacc.config'
local crontab = require 'mdacc.crontab'

--local variables

local config=nil
local batch=nil

function main()
   local fhd=io.open(config.runnow,"r")
   if (crontab.canRun(config.cron.tab,os.ts.date("*t")) or fhd~=null) then 
      --iguana will expire init cache.  Need to call each time.
      batch:init(config.transport.parameters)
      local fileList=batch:list(config.source.path,config.source.files)
      batch:get(config.source.path,config.destination.path,fileList)
-- Only activate when ready
--      batch:delete(config.source.path,fileList)
      if (#fileList == 0) then
         iguana.logWarning("There is no input files on "..config.transport.protocol..' location '..config.source.path)
      else
         queue.push{data=config.source.path}  --push to next processing channel
      end
      ---Cron function

      if (fhd ~=nil ) then
         fhd:close()
         os.remove(config.runnow)
      end
   end
end

function main_init()  -- load config 
   config = mda_config.loadConfig(me.appID)
   config._configRoot=  os.getenv("mda_appconfig")..'/'..me.appID..'/'
   config.runnow = config._configRoot..config.cron.runnow
   batch= require('mdacc.batch.transport.base')('sftp',config.transport.parameters,config.retry)
end


main_init()