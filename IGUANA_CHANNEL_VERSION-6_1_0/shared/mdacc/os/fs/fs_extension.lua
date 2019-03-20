local retry=require('interfaceware.retry')
local glob = require 'mdacc.io.file_glob'

local pattern='(.-)([^\\/]-%.?([^.\\/]*))$'

local function CopyFileOld(src, dest)
	local fin = io.open(src, "r")
	local fout = io.open(dest, "w")
	fout:write(fin:read("*a"))
	fout:close()
	fin:close()
end

local function CopyFileWindows(src,dest)
   local cp=[["copy"]]
   local command=cp ..' '..src..' '..dest

   local status =os.execute(command)
   if status == 0 then
      return true
   else
      error("Fail to run WinZip")
   end   
end

local function CopyFileLinux(src,dest)
   local cp=[["cp"]]
   local command=cp ..' '..src..' '..dest

   local status =os.execute(command)
   if status == 0 then
      return true
   else
      error("Fail to run WinZip")
   end   
end

function os.fs.FindFilesThatMatch(List, pattern)
   local Result = {}
   local lua_pattern=glob.globtopattern(pattern)
   if List==nil then return nil end
   for i=1, #List do
      if List[i]:find(pattern)~=nil then
         Result[#Result+1] = List[i]
      end
   end
   return Result
end

function os.fs.getFileName(file)
   local _,fname,_ = file:match(pattern)
   return fname
end

function os.fs.getFilePath(file)
   local path,_,_ = file:match(pattern)
   return path
end

function os.fs.getFileExtension(file)
   local _,fname,fext = file:match(pattern)
   if fext ~= fname then
      return fext
   else
      return nil
   end
end

local retryconfig={}
local fsconfig={}

function os.fs.init(config)
   fsconfig=config.transport
   retryconfig=config.retry
end

function os.fs.get(list)
   if (os.getenv('OS')==nil) then --Linux else Windows
      CopyFile=CopyFileLinux
   else
      CopyFile=CopyFileWindows
   end

   for i=1,#list do
      local remote_path=fsconfig.remotedir..list[i]
      local local_path=fsconfig.localdir..list[i]
      trace(remote_path)
      trace(local_path)
      local flag,errormsg=retry.call{func=CopyFile,arg1=remote_path,arg2=local_path,retry=retryconfig.times,pause=retryconfig.pause,funcname='os.fs.get'}
   end
end

function os.fs.delete(list,direction)
   local source_path=nil
   if (direction=='remote') then
      source_path = fsconfig.remotedir
   else
      source_path = fsconfig.localdir
   end
   
   for i=1,#list do
      local targetfile=source_path..list[i]
      local flag,errormsg = retry.call{func=os.remove,arg1=targetfile,retry=retryconfig.times,pause=retryconfig.pause,funcname='os.fs.delte'}
      if flag==nil then
         error(errormsg)
      end
   end
end

local function getList(table,source_path)
   local list=retry.call{func=os.fs.glob,arg1=source_path,retry=retryconfig.times,pause=retryconfig.pause,funcname='os.fs.list'}
-- filestat maybe nil
   for filename, fileinfo in list do
      trace(filename)
      if fileinfo.isreg == true then
         table[#table+1]=os.fs.getFileName(filename)-- we have full path
      end
   end 
end

function os.fs.list(direction)
   local source_path=nil
   local source_patterns=nil   
   local FileList={}
   
   -- get list of each filter
   -- verify that path contain \ or / at the end.  If not please added.
   if (direction=='remote') then
      source_path = fsconfig.remotedir
      source_patterns=fsconfig.remotefiles
   else
      source_path = fsconfig.localdir
      source_patterns=fsconfig.localfiles
   end
   for i=1, #source_patterns do
      getList(FileList,source_path..source_patterns[i])
   end

   return FileList
end

function os.fs.put(list)
   if (os.getenv('OS')==nil) then --Linux else Windows
      CopyFile=CopyFileLinux
   else
      CopyFile=CopyFileWindows
   end

   for i=1,#list do
      local remote_path=fsconfig.remotedir..list[i]
      local local_path=fsconfig.localdir..list[i]
      local flag,errormsg=retry.call{func=CopyFile,arg1=local_path,arg2=remote_path,retry=retryconfig.times,pause=retryconfig.pause,funcname='os.fs.put'}
   end
end

function os.fs.rename(oldname,newname)
   local oname=fsconfig.localdir..oldname
   local nname=fsconfig.localdir..newname
   local flag,errormsg=retry.call{func=os.rename,arg1=oname,arg2=nname,retry=retryconfig.times,pause=retryconfig.pause,funcname='os.fs.rename'}
   if flag==nil then
      error(errormsg)
   end
end

local function runWinZip(spath,filename)
   local winzip=[["C:\Program Files\WinZip\WZZIP.exe" -ybc ]]
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

function os.fs.archive(archFileName,sourcePath)
   if (os.getenv('OS')==nil) then --Linux else Windows
	   archFunc=runTar
   else
      archFunc=runWinZip
   end
   local flag,errormsg=retry.call{func=archFunc,arg1=sourcePath,arg2=archFileName,retry=retryconfig.times,pause=retryconfig.pause,funcname='os.fs.archive'}
   return flag,errormsg
end
