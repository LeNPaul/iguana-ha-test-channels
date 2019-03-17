local filter={}

local _private=setmetatable({},{__mode='k'})

local status

local function throw()
   error(status)
end

local meta={__index=function(table,key)
      local path='filter.'
      if ( _private[table]['prefix']~=nil) then
         path=path.. _private[table]['prefix']..'_'..key  
      else
         trace( _private[table]['prefix'])
         path=path..key       
      end
      trace(path)
     
      local success,func= pcall(require,path)
      if success then
         table[key]=func
      else
         --call default filter        
         if (func:match("not found:") == nil) then  --< this is error and it is not module not found
            status=func
            table[key]=throw
         else
            local success, func = pcall(require, 'filter.default')
            if success then
               table[key]=func
            else
               if (func:match("not found:") == nil) then  --< this is error and it is not module not found
                  status=func
                  table[key]=throw
               else 
                  status = nil
                  table[key]=function(msg)
                     return false
                  end
               end
            end
         end
      end
      return table[key]
   end,
   __call=function(table,prefix)
      trace(prefix,func)
      _private[table]={}
      _private[table]['prefix']=prefix 
      return table
   end
}

filter.__index=filter
setmetatable(filter,meta)
return filter  
