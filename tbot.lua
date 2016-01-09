-- Define global variables
chatCommands = {} -- chatCommands[command] = function of command
mainGroup = "T-Bot_Dev_Chat"
botName = "T-Bot"
defaultFilePath = "/home/pi/telegram/lua/tbot.lua"
libPath = "/home/pi/telegram/lua/libs/"
modulePath = "/home/pi/telegram/lua/modules/"

local admins = {"David_Enderlin", "Johann_Chervet", "Marco_von_Raumer", "T-Bot", "Marcel_Schmutz"}

------ Event handling ------
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
		if(string.sub(msg.text,1,1) == "!" or string.sub(msg.text,1,1) == "/") then -- Hier kommt ein Befehl
			mark_read(msg.to.print_name, no_sense, false) -- Hat Nachricht gelesen
			local subStrings = {}
			for subStr in string.gmatch(string.sub(msg.text,2),"%S+") do table.insert(subStrings, subStr) end -- Chatnachricht parsen
			
			local args = {}
			args = deepcopy(subStrings) -- Kopie des Arrays anlegen
			table.remove(args,1) -- Erstes Element ist der Befehl, deshalb erstes Element löschen um Argumente zu bekommen
			
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
					if (quoteClosed or command == "lua" or command == "luas") then -- Lua Befehl soll quote Regelung ignorieren
						chatCommands[command](msg, qArgs)
					else -- Wenn beim Quotes parsen ein Problem aufgetreten ist
						send_text(msg.to.print_name, "["..botName.."] Error: Not every quote is closed!")
					end
					break
				end
			end
			
			if (not commandExist) then -- Wenn Befehl nicht existiert hat
				send_text(msg.to.print_name, "["..botName.."] Unknown command")
			end
		else
			if toTbot then
				mark_read(msg.to.print_name, no_sense, false) -- Nachricht gelesen
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
	
	return false
end

-- Function to easily send a message
function send_text(peer, msg)
	send_msg(peer, msg, no_sense, false)
end

-- Empty callback function for tg-cli functions
function no_sense(extra, success, result)
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
			postpone(chatCommands["reload"], false, 1) -- Safety delay to give the update process some time
		else
			send_text(msg.to.print_name, "["..botName.."][Update] Already up-to-date.")
		end
	else
		send_text(msg.to.print_name, "["..botName.."] Admin-Only Command")
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
	else
		send_text(msg.to.print_name, "["..botName.."] Admin-Only Command")
	end
end)

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
loadLibs()
loadModules()
config.load() -- Load the config file
send_text(mainGroup, "["..botName.."] T-Bot initialized!")