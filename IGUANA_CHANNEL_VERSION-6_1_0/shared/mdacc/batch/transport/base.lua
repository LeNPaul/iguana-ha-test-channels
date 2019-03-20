-- uniform transport for batch module
local me = {_TYPE='module', _NAME='mdacc.batch.transport.base', _VERSION='1.0'}

-- base class for ftp, ftps, sftp

local transport={}
transport.__index=transport

setmetatable(transport, {
      __call = function (cls,...)
      return cls.new(...)
      end,
      }
   )

function transport.new(method,parameters,retry)
   if (method ~='fs') then
      self=require('mdacc.batch.transport.module.tcp_transport')(method,parameters,retry)
   else
      self=require('mdacc.batch.transport.module.fs_transport')(method,parameters,retry)
   end
   return self
end

return transport
