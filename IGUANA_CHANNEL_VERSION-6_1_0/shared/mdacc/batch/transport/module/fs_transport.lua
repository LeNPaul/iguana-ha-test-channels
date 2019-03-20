local me = {_TYPE='module', _NAME='mdacc.batch.transport.module.fs_transport', _VERSION='1.0'}

-- local module
local retry=require('interfaceware.retry')

-- local constant
local pattern='(.-)([^\\/]-%.?([^.\\/]*))$'

-- local support function

function getFileName(file)
   local _,fname,_ = file:match(pattern)
   return fname
end

function getFilePath(file)
   local path,_,_ = file:match(pattern)
   return path
end

function getFileExtension(file)
   local _,fname,fext = file:match(pattern)
   if fext ~= fname then
      return fext
   else
      return nil
   end
end

local function CopyFileWindows(src,dest)
   local cp=[["copy"]]
   local command=cp ..' '..src..' '..dest

   local status =os.execute(command)
   if status == 0 then
      return true
   else
      error("Fail to run copy")
   end   
end

local function CopyFileLinux(src,dest)
   local cp=[["cp"]]
   local command=cp ..' '..src..' '..dest

   local status =os.execute(command)
   if status == 0 then
      return true
   else
      error("Fail to run cp")
   end   
end

local function copy(source,dest)
   if (os.getenv('OS')==nil) then --Linux=nil else Windows=Windows_NT 
      -- Linux
      return CopyFileLinux(source,dest)
    else
      -- Windows
      return CopyFileWindows(source,dest)
   end   
end

local function runWinZip(spath,filename)
   local winzip=[["C:\Program Files\WinZip\WZZIP.exe" -ybc]]
   local command=winzip ..' '..filename..' '..spath..'*'

   local status =os.execute(command)
   if status == 0 then
      return true
   else
      error("Fail to run WinZip")
   end
end


local function runTar(spath,filename)
   local command='tar czf '..filename..' -C '..spath..' .'
   local status =os.execute(command)
   if status == 0 then
      return true
   else
      error("Fail to run tar")
   end   
end

local function archiver(spath,filename)
   if (os.getenv('OS')==nil) then --Linux=nil else Windows=Windows_NT 
      -- Linux
      return runTar(spath,filename..'.tar.gz')
   else
      -- Windows
      return runWinZip(spath,filename..'.zip')
   end
end 

-- class
local transport={}

transport.__index=transport

setmetatable(transport, {
      __call = function (cls,...)
      return cls.new(...)
      end,
      }
   )

function transport.new(method,parameters,retry)
   local self={transportMethod=method,retry=retry}
   setmetatable(self,transport)
   trace(getmetatable(transport))
   self.handle=transport
   return self
end

function transport:copy(source,dest,list)
   for i=1,#list do
      local source_file=source..list[i]
      local dest_file=dest..list[i]
      local flag,errormsg=retry.call{func=copy,arg1=source_file,arg2=dest_file,retry=self.retry.times,pause=self.retry.pause,funcname='transport.copy'}
   end
end

function transport:delete(source,list)
   for i=1,#list do
      local targetfile=source..list[i]
      local flag,errormsg = retry.call{func=os.remove,arg1=targetfile,retry=self.retry.times,pause=self.retry.pause,funcname='os.remove'}
      if flag==nil then
         error(errormsg)
      end
   end
end


local function getList(self,table,source_path)
   -- pattern must contain * or ?
   local list=retry.call{func=os.fs.glob,arg1=source_path,retry=self.retry.times,pause=self.retry.pause,funcname='os.fs.list'}
-- filestat maybe nil
   trace(list)
   for filename, fileinfo in list do
      trace(filename)
      if fileinfo.isreg == true then
         table[#table+1]=getFileName(filename)-- we have full path
      end
   end 
   trace('end')
end


function transport:list(path,patterns)
   local list = {}
   for i=1, #patterns do
      getList(self,list,path..patterns[i])
   end
   trace('bob')
   return list
end
   

function transport:rename(source,oldName,newName)
   local oname = source..oldName
   local nname = source..newName
   local flag,errormsg=retry.call{func=os.rename,arg1=oname,arg2=nname,retry=self.retry.times,pause=self.retry.pause,funcname='os.fs.rename'}
   if flag==nil then
      error(errormsg)
   end
end

function transport:archive(sourcePath,archiveFileName)
   local flag,errormsg=retry.call{func=archiver,arg1=sourcePath,arg2=archiveFileName,retry=self.retry.times,pause=self.retry.pause,funcname='os.fs.archive'}
   return flag,errormsg
end

return transport
