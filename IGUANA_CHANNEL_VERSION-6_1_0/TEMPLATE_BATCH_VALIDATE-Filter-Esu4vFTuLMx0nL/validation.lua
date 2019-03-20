
--local modules
local glob = require('mdacc.io.file_glob')

--local variables
local validate_functions={}

function validate_functions.hasFile(path,list,patterns,errors)
   for i=1,#patterns do
      local t=glob.FindFilesThatMatch(list,glob.globtopattern(patterns[i]))
      trace(#t)
      if (#t==0) then
         errors[#errors+1]='There is no file with the following pattern: '..patterns[i] 
         trace('file not found')
      end
   end
end

function validate_functions.isSizeZero(path,list,_,errors)
    for i=1,#list do
      local file=path..list[i]
      local stat =os.fs.stat(file)  --< pcall?
      if (stat.size==0) then
         errors[#errors+1]=file..' is empty'
      end
    end
end



local function validate(path,list,patterns)
   local errors={}
   if #list== 0 then return {"File not find on "..path} end
   for _,fn in pairs(validate_functions) do
       local t=fn(path,list,patterns,errors)
   end
	return errors
end

return validate