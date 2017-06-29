-- Define important global variables
mainGroup = "T-Bot_Dev_Chat"
botName = "T-Bot"

-- Path definitions
installPath = "/home/pi/tg/lua"
defaultFilePath = installPath.."/tbot.lua"
libPath = installPath.."/libs/"
modulePath = installPath.."/modules/"



------ Core helper function ------

-- Function to execute "cmd" in the standard command line and returns it's output.
-- is needed to initialize
function os.capture(cmd, raw, timeout)
	if not timeout then
		timeout = 30
	end
	-- wrap command with timeout (exits after timeout, kills after timeout + 5)
	local command = "timeout -k "..(timeout + 5).." "..timeout.." "..cmd.." 2>&1"
	local f = assert(io.popen(command, 'r'))
	local s = assert(f:read('*a'))
	f:close()
	if raw then return s end
	s = string.gsub(s, '^%s+', '')
	s = string.gsub(s, '%s+$', '')
	s = string.gsub(s, '[\n\r]+', ' ')
	return s
end

-- Register interface commands
function registerCommands()
	-- usage: register_interface_function("name", function, extra, "help description", "arg1_type", ["arg2_type", ...])
	-- possible arg_types: user, chat, secret_chat, peer, file_name, file_name_end, period, number, double, string_end, string
	if register_interface_function("interval", on_cron_interval, "", "interval <string>       triggers on_cron_interval event", "string") then
		_print("registered interval command!")
	else
		print("Error registering interval command")
	end
end

-- Load libraries
function loadLibs()
	local lsStr = os.capture("ls "..libPath)
	local libs = {}
	for file in string.gmatch(lsStr, "%a+.lua") do 
		local func, errorStr = loadfile(libPath..file) 
		if func then
			local success, errorStr = pcall(func)
			if success then
				_print("Library ("..file..") loaded!")
			else
				print("Error running library ("..file.."):\n"..errorStr)
			end
		else
			print("Error loading library ("..file.."):\n"..errorStr)
		end
	end
end

-- Load modules
function loadModules()
	local lsStr = os.capture("ls "..modulePath)
	local modules = {}
	for file in string.gmatch(lsStr, "%a+.lua") do 
		local func, errorStr = loadfile(modulePath..file) 
		if func then
			local success, errorStr = pcall(func)
			if success then
				_print("Module ("..file..") loaded!")
			else
				print("Error loading module ("..file.."):\n"..errorStr)
			end
		else
			print("Error loading module ("..file.."):\n"..errorStr)
		end
	end
end

------ Initialize ------

if not _print then
	local p = print
	function _print(...)
		p("[Lua]", ...)
	end
	function print(...) 
		if lastmsg then
			send(lastmsg.to.print_name, "[Print]", ...)
		elseif log then
			log("[Print]", ...)
		else
			_print(...)
		end
	end
end

loadLibs()			-- Load essential libraries
config.load()		-- Load the config file

if not started then								-- Prevent multiple executions
	hook.add("on_startup_ready", "firstStart", function()
		started = true
		loadModules()
		log("T-Bot initialized!")
	end)	
	
	get_contact_list(void, nil)					-- Get contact_list to send messages
	get_dialog_list(on_startup_ready, nil)		-- Get dialog list to send messages
	registerCommands()							-- Registers interface commands
else
	loadModules()		-- reload additional modules
	log("T-Bot reloaded!")
end