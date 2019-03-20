-- The main function is the first function called from Iguana.
local me = {appID='template_batch_fs_in'}

--load module
local mda_config = require ('mdacc.config')
local crontab = require ('mdacc.crontab')

--local variable
local config=nil
local batch = nil

function main()
   --- Cron function

   local fhd=io.open(config.runnow,"r")
   if (crontab.canRun(config.cron.tab,os.ts.date("*t")) or fhd~=null) then
      local fileList = batch:list(config.source.path,config.source.files)
      batch:copy(config.source.path,config.destination.path,fileList)
-- You need to enable it when you're sure that it work.
--      batch:delete(config.source.path,fileList)
      if (#fileList == 0) then
         iguana.logWarning("There is no input files on "..config.source.path)
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
   batch= require('mdacc.batch.transport.base')('fs',nil,config.retry)
end

main_init()