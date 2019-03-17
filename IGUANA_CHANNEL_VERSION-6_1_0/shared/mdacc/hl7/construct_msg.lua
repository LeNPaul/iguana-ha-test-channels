local construct={}

local _private={}
setmetatable(_private,{__mode='k',
      __index=function(table,key)
         return nil
      end
   })

local status

local function throw()
   error(status)
end

local meta={__index=function(table,key)
      local path='xlate.'
      if ( _private[table]['prefix']) then
         path=path.. _private[table]['prefix']..'_'..key  
      else
         path=path..key       
      end
      trace(path)
      
      local success,func = pcall(require,path)
      if success then
         table[key]=func
      else
         if (func:match("not found:") == nil) then  --< this is error and it is not module not found
            status=func
            table[key]=throw
         else
            status = nil
            table[key]=function(msg,msgType)
               queue.push{data=msg:S()}
            end
         end
      end
      return table[key]
   end,   __call=function(table,prefix)
      _private[table]={}
      _private[table]['prefix']=prefix
      trace(_private[table]['prefix'])
      return table
   end
}

construct.__index = construct
setmetatable(construct,meta)

return construct  
