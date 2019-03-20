local config ={}

local function getappconfig()
   root = os.getenv("mda_appconfig")
   base = os.getenv("mda_appconfig_file")
   if ( root:sub(root:len(),1) ~= "/" ) then
      root = root.."/"
   end
   if (base:sub(1,1) ~= "/" ) then
      base = "/"..base
   end
end

function config.loadConfig(appname)
   getappconfig()
   local CONFIG_FILE=root..appname..base
   if not os.fs.access(CONFIG_FILE) then
      error("Config file not found at "..CONFIG_FILE)
   end
   local F = io.open(CONFIG_FILE, "r")
   local File = F:read("*a")
   local Config = json.parse{data=File}
   F:close()
   return Config
   --Test
end

return config