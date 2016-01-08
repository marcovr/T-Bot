-- Globale Variablen definieren
chatCommands = {} -- chatCommands[x].command = string des commands / chatCommands[x].func = function des commands
mainGroup = "T-Bot_Dev_Chat"
botName = "T-Bot"
TGNumber = "Telegram"
defaultFilePath = "/home/pi/telegram/lua/tbot.lua"
libPath = "/home/pi/telegram/lua/libs/"
modulePath = "/home/pi/telegram/lua/modules/"
cage = 1

local admins = {"David_Enderlin", "Johann_Chervet", "Marco_von_Raumer", "T-Bot", "Marcel_Schmutz"}

------ Event handling ------
function on_binlog_replay_end()
	hook.Call("tg_BinLogReplayEnd")
end

function on_get_difference_end()
	hook.Call("tg_GetDifferenceEnd")
	--reminderCheck()
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
			for k, v in pairs(chatCommands) do
				if(chatCommands[k].command == string.lower(subStrings[1])) then
					commandExist = true
					if (quoteClosed or chatCommands[k].command == "lua" or chatCommands[k].command == "luas") then -- Lua Befehl soll quote Regelung ignorieren
						chatCommands[k].func(msg, qArgs)
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
				if msg.from.print_name == TGNumber then
					send_text(mainGroup, "["..botName.."] "..msg.text)
				else
					--os.execute("php -f /var/www/maclog/php/telegram/chat.php "..msg.to.print_name.." "..msg.text)
					send_text(msg.to.print_name, "["..botName.."] Cleverbot API is no longer available")
				end
			end
		end
	end
end

function parseMsg(message)
	local subStrings = {} -- Alle mit Leerzeichen getrennten Teile des Befehls
	for subStr in string.gmatch(string.sub(msg.text,2),"%S+") do table.insert(subStrings, subStr) end -- Chatnachricht zerteilen
	local cmd = string.lower(subStrings[1]) -- Befehl in Variable speichern
	table.remove(subStrings,1) -- Erstes Element ist der Befehl, deshalb erstes Element löschen um Argumente zu bekommen
	
	local args = {}
	
	local quoteClosed = true
	local skipTo = 1
	
	for k, v in pairs(subStrings) do -- Quotes parsen
		if(string.sub(v, -1) == "\"" and string.sub(v, 1, 1) == "\"") then -- Wenn Anfangsquote auch Endquote ist
			table.insert(args, string.sub(v, 2, -2))
		elseif(string.sub(v, 1, 1) == "\"") then -- Wenn Anfangsquote gefunden wurde
			quoteClosed = false
			for i=k+1,#subStrings do -- Durch alle restlichen Argumente gehen und Endquote suchen
				if(string.sub(subStrings[i], -1) == "\"") then -- Wenn Endquote gefunden wurde
					quoteClosed = true -- Quote wurde geschlossen
					local quoteArg = ""
					quoteArg = quoteArg..string.sub(v, 2) -- Argument mit Anfangsquote zu quoteArg hinzufügen
					for j=k+1,i-1 do -- Von Anfangs+1 bis Endquote-1 durchgehen
						quoteArg = quoteArg.." "..subStrings[j] -- Argumente zwischen Anfangs und Endquote zu quoteArg hinzufügen
					end
					quoteArg = quoteArg.." "..string.sub(subStrings[i], 1, -2) -- Argument mit Endquote zu quoteArg hinzufügen
					skipTo = i+1 -- Bis nach die Quote skippen
					table.insert(args, quoteArg) -- quoteArg in neues Argument-Table hinzufügen
					break
				end
			end
		else
			if(k >= skipTo) then -- Erst wenn loop nach der letzten Quote ist wieder einzelne Elemente inserten
				table.insert(args, v)
			end
		end
	end
	
	return cmd, args	-- cmd: commandname , options: array mit options , args: array mit argumenten
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

------ Diverse Hilfs-functions ------
function booleanvalue(bool)
	if bool then
		return "TRUE"
	else
		return "FALSE"
	end
end

-- Function um neuen chat command zu machen
function addCommand(command, func)
	local temp = {}
	temp.command = command
	temp.func = func
	
	table.insert(chatCommands, temp)
end

-- Überprüft ob der absender der msg admin ist
function isAdmin(msg)
	for k, v in pairs(admins) do
		if(msg.from.print_name == v) then
			return true
		end
	end
	
	return false
end

-- Function um einen einfachen Text zu versenden
function send_text(peer, msg)
	send_msg(peer, msg, no_sense, false)
end

-- Führt einen Befehl aus und gibt string zurück
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

-- Macht eine Kopie eines Tables
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Callback function von telegram-cli functions
function no_sense(extra, success, result)
end

-- Table Serialization Shit
-- Braucht man um das Tables zu analysieren
local function exportstring( s )
  return string.format("%q", s)
end

-- The Table display Function
function table.show(tbl)
  local charS,charE = "   ","\n"
  local file = ""
  if err then return err end

  -- initiate variables for display procedure
  local tables,lookup = { tbl },{ [tbl] = 1 }
  file = file .. ( "return {"..charE )

  for idx,t in ipairs( tables ) do
	 file = file .. ( "-- Table: {"..idx.."}"..charE )
	 file = file .. ( "{"..charE )
	 local thandled = {}

	 for i,v in ipairs( t ) do
		thandled[i] = true
		local stype = type( v )
		-- only handle value
		if stype == "table" then
		   if not lookup[v] then
			  table.insert( tables, v )
			  lookup[v] = #tables
		   end
		   file = file .. ( charS.."{"..lookup[v].."},"..charE )
		elseif stype == "string" then
		   file = file .. (  charS..exportstring( v )..","..charE )
		elseif stype == "number" then
		   file = file .. (  charS..tostring( v )..","..charE )
		end
	 end

	 for i,v in pairs( t ) do
		-- escape handled values
		if (not thandled[i]) then
		
		   local str = ""
		   local stype = type( i )
		   -- handle index
		   if stype == "table" then
			  if not lookup[i] then
				 table.insert( tables,i )
				 lookup[i] = #tables
			  end
			  str = charS.."[{"..lookup[i].."}]="
		   elseif stype == "string" then
			  str = charS.."["..exportstring( i ).."]="
		   elseif stype == "number" then
			  str = charS.."["..tostring( i ).."]="
		   end
		
		   if str ~= "" then
			  stype = type( v )
			  -- handle value
			  if stype == "table" then
				 if not lookup[v] then
					table.insert( tables,v )
					lookup[v] = #tables
				 end
				 file = file .. ( str.."{"..lookup[v].."},"..charE )
			  elseif stype == "string" then
				 file = file .. ( str..exportstring( v )..","..charE )
			  elseif stype == "number" then
				 file = file .. ( str..tostring( v )..","..charE )
			  end
		   end
		end
	 end
	 file = file .. ( "},"..charE )
  end
  file = file .. ( "}" )
  
  return file
end

------ Standard Chat Commands ------
addCommand("ping", function(msg, args)
	send_text(msg.to.print_name, "["..botName.."] Pong!")
end)

--[[addCommand("luaf", function(msg, args)
	if(isAdmin(msg)) then
		if(#args > 0) then
			func, errorStr = loadfile(string.sub(msg.text,7)) -- 
			if(func == nil) then
				send_text(msg.to.print_name, "["..botName.."] An error occured while running the script:\n"..errorStr)
			else
				func()
			end
		else
			send_text(msg.to.print_name, "["..botName.."] Usage: luaf <filepath>")
		end
	else
		send_text(msg.to.print_name, "["..botName.."] Admin-Only Command")
	end
end)]]--

addCommand("lua", function(msg, args)
	if(isAdmin(msg)) then
		if(#args > 0) then
			local input = string.sub(msg.text,6)
			local output = false
			local file = false
			local analyzing = true
			
			while analyzing do
				analyzing = false
				if string.sub(input, 0, 2) == "-x" then
					input = string.sub(input, 4)
					output = true
					analyzing = true -- Weiter processen
				elseif string.sub(input, 0, 2) == "-f" then
					input = string.sub(input, 4)
					file = true
					analyzing = true -- Weiter processen
				elseif string.sub(input, 0, 2) == "-E" then
					input = "\"Easter-Eggs are cool!\""
					output = true
					file = false
					--analyzing = true Alle weiteren Argumente sollen ignoriert werden
				end
			end
			
			if file then
				func, errorStr = loadfile(input) -- 
			elseif output then
				input = "return "..input
				func, errorStr = loadstring(input) --
			else
				func, errorStr = loadstring(input) --
			end
			
			if(func == nil) then
				send_text(msg.to.print_name, "["..botName.."] An error occured while running the script:\n"..errorStr)
			else
				if output then
					local output = func()
					if output == nil then
						output = "[nil]"
					elseif output == "" then
						output = "[Empty]"
					elseif output == " " then
						output = "[Space]"
					end
					send_text(msg.to.print_name, "["..botName.."] "..output)
				else
					func()
				end
			end
		else
			send_text(msg.to.print_name, "["..botName.."] Usage: lua (-x, -f) <cmd>")
		end
	else
		send_text(msg.to.print_name, "["..botName.."] Admin-Only Command")
	end
end)

--[[
addCommand("luat", function(msg, args)
	if(isAdmin(msg)) then
		if(#args > 0) then
			postpone(loadstring(args[2]), false, args[1]) -- Kein Error Handling!
			]]--
			--[[
			func, errorStr = loadstring(args[2])
			if(func == nil) then
				send_text(msg.to.print_name, "["..botName.."] An error occured while running the script:\n"..errorStr)
			else
				func()
			end]]--
			--[[
		else
			send_text(msg.to.print_name, "["..botName.."] Usage: luat <timeout> \"code\"")
		end
	else
		send_text(msg.to.print_name, "["..botName.."] Admin-Only Command")
	end
end)
]]--

addCommand("sh", function(msg, args)
	if(isAdmin(msg)) then
		if(#args > 0) then
			output = tostring(os.capture(string.sub(msg.text,5), true))
			if(output ~= "") then
				send_text(msg.to.print_name, output)
			else
				send_text(msg.to.print_name, "["..botName.."] Empty")
			end
		else
			send_text(msg.to.print_name, "["..botName.."] Usage: sh <shellcmd>")
		end
	else
		send_text(msg.to.print_name, "["..botName.."] Admin-Only Command")
	end
end)

addCommand("argtest", function(msg, args)
	if(#args > 0) then
		for k, v in pairs(args) do
			send_text(msg.to.print_name, "Args["..k.."] = "..v)
		end
	else
		send_text(msg.to.print_name, "["..botName.."] Usage: argtest <arg1> [<arg2> <arg3> ...]")
	end
end)

addCommand("ls", function(msg, args)
	local cmds = ""
    for index,value in pairs(chatCommands) do
        if value.command ~= "getuser" then
            cmds = cmds..value.command.."\n"
        end
    end
    send_text(msg.to.print_name, "["..botName.."] Available commands:\n"..cmds)
end)

--[[
addCommand("getuser", function(msg, args)
	if(msg.to.print_name == "Tiger_Tiger") then -- Befehl auf Tiger_Tiger Gruppe begrenzen
		if(isAdmin(msg)) then
			if(#args > 0) then
				os.execute("php -f /var/www/maclog/php/telegram/GetUserData.php "..args[1])
			else
				send_text("Tiger_Tiger", "["..botName.."] Usage: getuser <user>")
			end
		else
			send_text(msg.to.print_name, "["..botName.."] Admin-Only Command")
		end
	else
		send_text(msg.to.print_name, "["..botName.."] Unknown command")
	end
end)
]]--

addCommand("update", function(msg, args)
	if(isAdmin(msg)) then
		local text = os.capture("cd /home/pi/telegram/lua/ && git pull")
		send_text(msg.to.print_name, "["..botName.."][Update] ".. text)
		if (text ~= "Already up-to-date.") then
			func, errorStr = loadfile(defaultFilePath)
			if(func == nil) then
				send_text(msg.to.print_name, "["..botName.."] An error occured while running the script:\n"..errorStr)
			else
				func()
			end
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

addCommand("about", function (msg, args)
	send_text(msg.to.print_name, "["..botName.."] is being developed by:\n - Marco von Raumer\n - David Enderlin\n - Marcel Schmutz\n©2014") 
end)

-- Unnötige funktion um zu reden mit T-Bot
addCommand("talk", function(msg, args)
	if(#args > 0) then
		--os.execute("php -f /var/www/maclog/php/telegram/chat.php "..msg.to.print_name.." "..args[1])
		send_text(msg.to.print_name, "["..botName.."] Cleverbot API is no longer available")
	else
		send_text(msg.to.print_name, "["..botName.."] Usage: talk <msg>")
	end
end)

------ Postpone functions ------
--[[
function changePicture() -- Jede Minute Cage Bild ändern
	if(cage > 3) then
		cage = 1
	end
	
	set_profile_photo("/home/pi/cage"..tostring(cage)..".jpg", no_sense, false)
	postpone(changePicture, false, 60) -- changePicture in 60s ausführen -> loop
	
	cage = cage + 1
end

postpone(changePicture, false, 60) -- changePicture in 60s ausführen
]]--

------ Libraries Laden ------
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

------ Module Laden ------
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

-- Nachricht anzeigen dass Bot initialisiert wurde
loadLibs()
loadModules()
config.load() -- Load the config file
send_text(mainGroup, "["..botName.."] T-Bot initialized!")
