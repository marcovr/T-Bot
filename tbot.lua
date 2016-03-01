-- Define global variables
chatCommands = {} -- chatCommands[command] = function of command
mainGroup = "T-Bot_Dev_Chat"
botName = "T-Bot"
defaultFilePath = "/home/pi/telegram/lua/tbot.lua"
libPath = "/home/pi/telegram/lua/libs/"
modulePath = "/home/pi/telegram/lua/modules/"

local admins = {"David_Enderlin", "Johann_Chervet", "Marco_von_Raumer", "T-Bot", "Marcel_Schmutz"}

------ Event handling ------
function on_startup_ready() -- gets triggered after startup as soon as messaging is ready
	print("[LUA] ready for messaging!")
	hook.Call("on_startup_ready")
end

function on_cron_interval() -- gets triggered every 5 minutes by cronjob
	print("[LUA] cron interval triggered!")
	hook.Call("on_cron_interval")
end

function on_binlog_replay_end()
	hook.Call("tg_BinLogReplayEnd")
end

function on_get_difference_end()
	hook.Call("tg_GetDifferenceEnd")
end

function on_our_id(our_id)
	hook.Call("tg_OurId", our_id)
end

function on_msg_receive(msg)
	local toTbot = false
	
	if(msg.from.print_name ~= botName) then
		hook.Call("tg_MsgReceive", msg)
		
		if(msg.to.print_name == botName) then
			msg.to.print_name = msg.from.print_name
			toTbot = true
		end
	end
		
	if(msg.text ~= nil) then
		if(string.sub(msg.text,1,1) == "!" or string.sub(msg.text,1,1) == "/") then
			mark_read(msg.to.print_name, no_sense, false) -- Mark message as read
			local subStrings = {}
			for subStr in string.gmatch(string.sub(msg.text,2),"%S+") do table.insert(subStrings, subStr) end -- Split message
			
			local args = {}
			args = deepcopy(subStrings) -- Make a true copy of array
			table.remove(args,1) -- Remove first element, since it's the command itself
			
			local qArgs = {}
			
			local quoteClosed = true
			local skipTo = 1
			
			for k, v in pairs(args) do -- Quotes parsen
				if(string.sub(v, -1) == "\"" and string.sub(v, 1, 1) == "\"") then -- Wenn Anfangsquote auch Endquote ist
					table.insert(qArgs, string.sub(v, 2, -2))
				elseif(string.sub(v, 1, 1) == "\"") then -- Wenn Anfangsquote gefunden wurde
					quoteClosed = false
					for i=k+1,#args do -- Durch alle restlichen Argumente gehen und Endquote suchen
						if(string.sub(args[i], -1) == "\"") then -- Wenn Endquote gefunden wurde
							quoteClosed = true -- Quote wurde geschlossen
							local quoteArg = ""
							quoteArg = quoteArg..string.sub(v, 2) -- Argument mit Anfangsquote zu quoteArg hinzufügen
							for j=k+1,i-1 do -- Von Anfangs+1 bis Endquote-1 durchgehen
								quoteArg = quoteArg.." "..args[j] -- Argumente zwischen Anfangs und Endquote zu quoteArg hinzufügen
							end
							quoteArg = quoteArg.." "..string.sub(args[i], 1, -2) -- Argument mit Endquote zu quoteArg hinzufügen
							skipTo = i+1 -- Bis nach die Quote skippen
							table.insert(qArgs, quoteArg) -- quoteArg in neues Argument-Table hinzufügen
							break
						end
					end
				else
					if(k >= skipTo) then -- Erst wenn loop nach der letzten Quote ist wieder einzelne Elemente inserten
						table.insert(qArgs, v)
					end
				end
			end

			local commandExist = false
			local command = string.lower(subStrings[1])
			for k, v in pairs(chatCommands) do
				if(chatCommands[command] ~= nil) then
					commandExist = true
					if (quoteClosed or command == "lua" or command == "luas" or command == "sh") then -- Lua and Shell command should ignore quotes
						chatCommands[command](msg, qArgs)
					else -- If there are unclosed quotes
						send_text(msg.to.print_name, "["..botName.."] Error: Not every quote is closed!")
					end
					break
				end
			end
			
			if (not commandExist) then -- If command wasn't existing
				send_text(msg.to.print_name, "["..botName.."] Unknown command")
			end
		else
			if toTbot then
				mark_read(msg.to.print_name, no_sense, false) -- Mark message as read
				if msg.from.print_name == "Telegram" then
					send_text(mainGroup, "["..botName.."] "..msg.text)
				end
			end
		end
	end
end

function on_user_update(user, what_changed)
	hook.Call("tg_UserUpdate", user, what_changed)
end

function on_chat_update(user, what_changed)
	hook.Call("tg_ChatUpdate", user, what_changed)
end

function on_secret_chat_update(user,what_changed)
	hook.Call("tg_SecretChatUpdate", user, what_changed)
end

------ Some core helper functions ------
function booleanvalue(bool)
	if bool then
		return "TRUE"
	else
		return "FALSE"
	end
end

-- Adds a new chat command
function addCommand(command, func)
	chatCommands[command] = func
end

-- Checks if sender is admin
function isAdmin(msg)
	for k, v in pairs(admins) do
		if(msg.from.print_name == v) then
			return true
		end
	end
	send_text(msg.to.print_name, "["..botName.."] Admin-Only Command")
	return false
end

-- Function to easily send a message
function send_text(peer, msg)
	send_msg(peer, msg, no_sense, false)
end

-- Empty callback function for tg-cli functions
function no_sense(extra, success, result)
end

-- Function to execute "cmd" in the standard command line and returns it's output.
-- is needed to initialize
function os.capture(cmd, raw)
	local f = assert(io.popen(cmd, 'r'))
	local s = assert(f:read('*a'))
	f:close()
	if raw then return s end
	s = string.gsub(s, '^%s+', '')
	s = string.gsub(s, '%s+$', '')
	s = string.gsub(s, '[\n\r]+', ' ')
	return s
end

------ Vital Chat Commands ------
addCommand("update", function(msg, args)
	if(isAdmin(msg)) then
		os.capture("cd /home/pi/telegram/lua/ && git reset --hard")
		local text = os.capture("cd /home/pi/telegram/lua/ && git pull")
		if (text ~= "Already up-to-date.") then
			local beginPos, endPos, fromVersion, toVersion = string.find(text, "(%w+)%.%.(%w+)") 	-- Get version hashes
			text = string.sub(text, endPos+15)														-- Remove version hashes from string
			text = string.gsub(text, "([%+%-]+)%s", "%1\n")											-- Format file changes
			send_text(msg.to.print_name, "["..botName.."][Update] Updating from <".. fromVersion .."> to <".. toVersion .. ">\n"..text)
			postpone(chatCommands["reload"], {from={print_name="T-Bot"}}, 1)						-- Safety delay to give the update process some time (needs admin credentials)
		else
			send_text(msg.to.print_name, "["..botName.."][Update] Already up-to-date.")
		end
	end
end)

addCommand("reload", function(msg, args)
	if(isAdmin(msg)) then
		func, errorStr = loadfile(defaultFilePath)
		if(func == nil) then
			send_text(msg.to.print_name, "["..botName.."] An error occured while running the script:\n"..errorStr)
		else
			func()
		end
	end
end)

------ Register Commands -----
function registerCommands()
	-- Register startup command - used to trigger on_startup_ready
	-- usage: register_interface_function("name", function, extra, "help description", "arg1_type", ["arg2_type" ...])
	-- possible arg_types: user, chat, secret_chat, peer, file_name, file_name_end, period, number, double, string_end, string
	if (register_interface_function("interval", on_cron_interval, "", "interval <string>       triggers on_cron_interval event", "string")) then
		print("[LUA] registered interval command!")
	else
		send_text(mainGroup, "["..botName.."] Error registering interval command")
	end
end

------ Load Libraries ------
function loadLibs()
	lsStr = os.capture("ls "..libPath)
	local libs = {}
	for file in string.gmatch(lsStr, "%a+.lua") do 
		func, errorStr = loadfile(libPath..file) 
		if(func == nil) then
			send_text(mainGroup, "["..botName.."] Error loading library ("..file.."):\n"..errorStr)
		else
			func()
			print("[LUA] Library ("..file..") loaded!")
		end
	end
end

------ Load Modules ------
function loadModules()
	lsStr = os.capture("ls "..modulePath)
	local modules = {}
	for file in string.gmatch(lsStr, "%a+.lua") do 
		func, errorStr = loadfile(modulePath..file) 
		if(func == nil) then
			send_text(mainGroup, "["..botName.."] Error loading module ("..file.."):\n"..errorStr)
		else
			func()
			print("[LUA] Module ("..file..") loaded!")
		end
	end
end

-- Initialize
if (already_started_up == nil) then
	already_started_up = true					-- Prevent multiple executions
	get_contact_list(no_sense, false)			-- Get contact_list to send messages
	get_dialog_list(on_startup_ready, false)	-- Get dialog list to send messages
	registerCommands()							-- Registers interface commands
end

loadLibs()			-- Load essential libraries
config.load()		-- Load the config file
loadModules()		-- Load additional modules
send_text(mainGroup, "["..botName.."] T-Bot initialized!")