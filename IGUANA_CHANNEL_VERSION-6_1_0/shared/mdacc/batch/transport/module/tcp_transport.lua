local me = {_TYPE='module', _NAME='mdacc.batch.transport.module.tcp_transport', _VERSION='1.0'}

-- load module

local retry=require('interfaceware.retry')
local glob=require('mdacc.io.file_glob')

-- local constant


-- Local Method
local function FindFilesThatMatch(List, pattern)
   local Result = {}
   if List==nil then return nil end
   for j=1, #pattern do
      local currentPattern=glob.globtopattern(pattern[j])
   for i=1, #List do
      if List[i].is_retrievable==true then
         if List[i].filename:find(currentPattern)~=nil then
            Result[#Result+1] = List[i].filename
         end
      end
   end
   end
   return Result
end

-- base class for ftp, ftps, sftp

local transport={}
transport.__index=transport

setmetatable(transport, {
      __call = function (cls,...)
      return cls.new(...)
      end,
      }
   )
--[===[
function transport:init(parameters)
   self.handle=nil
   func='return net.'..self.transportMethod..'.init(parameters)'
   local func=loadstring(func,'myTransport')
   -- need env for local
   local env={net=net,parameters=parameters}
   setfenv(func,env)
   self.handle=func()
end
--]===]

function transport.new(method,parameters,retry)
   local self={transportMethod=method,retry=retry}
   setmetatable(self,transport)
   func='return net.'..self.transportMethod..'.init(parameters)'
   local func=loadstring(func,'myTransport')
   -- need env for local
   local env={net=net,parameters=parameters}
   setfenv(func,env) 
   self.init=func
   self.handle=self.init()
   return self
end

-- ok
function transport:delete(source,list)
   local FUNCName=self.transportMethod..'.delete'
   local params={}
   for i=1, #list do
      params.remote_path=source..list[i]
      trace(params)
      local flag=retry.call{func=self.handle.delete,arg1=self.handle,arg2=params,funcname=FUNCName,pause=self.retry.pause,retry=self.retry.times}
      if not flag then
         error('Fail to get file '..params.remote_path)
      end
   end   
end

-- ok

function transport:get(source,dest,list)
   local FUNCName=self.transportMethod..'.get'
   local params={overwrite=true}
   for i=1, #list do
      params.remote_path=source..list[i]
      params.local_path=dest..list[i]
      local flag=retry.call{func=self.handle.get,arg1=self.handle,arg2=params,funcname=FUNCName,pause=self.retry.pause,retry=self.retry.times}
      if not flag then
         error('Fail to get file '..params.remote_path)
      end
   end
end

-- ok
function transport:list(path,patterns)
   local FUNCName2=self.transportMethod..'.list'
   local params={remote_path=path}
   local list=retry.call{func=self.handle.list,arg1=self.handle, arg2=params,funcname=FUNCNAME,pause=self.retry.pause,retry=self.retry.times}
   return FindFilesThatMatch(list,patterns)
end

-- ok
function transport:put(source,dest,list)
   local FUNCName=self.transportMethod..'.put'
   local params={overwrite=true,tmp_postfix='ig_tmp'}
   for i=1, #list do
      params.remote_path=dest..list[i]
      params.local_path=source..list[i]
      local flag=retry.call{func=self.handle.put,arg1=self.handle,arg2=params,funcname=FUNCName,pause=self.retry.pause,retry=self.retry.times}
      if not flag then
         error('Fail to get file '..params.remote_path)
      end
   end   
end

-- ok
function transport:rename(source,oldName,newName)
   local FUNCName=self.transportMethod..'.rename'
   local params={}
   params.remote_path=source..oldName
   params.new_remote_path=source..newName
   trace(params)
   local flag=retry.call{func=self.handle.rename,arg1=self.handle,arg2=params,funcname=FUNCName,pause=self.retry.pause,retry=self.retry.times}
   if not flag then
      error('Fail to get file '..params.remote_path)
   end   
end

return transport
