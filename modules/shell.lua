-- Interactive shell module
-- Kann noch ne Weile dauern bis das fertig is
local ScreenName = "shell"													-- Name des Screens
local ScreenLogfile = "/home/pi/telegram/screenlog.0"						-- Pfad des Screenlogs
local NoScreenErrMsg = "No Sockets found in /var/run/screen/S-www-data." 	-- Error welcher kommt, wenn gesuchter Screen nicht gefunden wurde

local ActiveUsers = {}														-- Liste der User in der interactive Shell
local lastSize = 0

addCommand("shell", function(msg, args)
	if(isAdmin(msg)) then
		if(os.capture("screen -ls "..ScreenName) == NoScreenErrMsg) then -- Wenn noch kein screen existiert, erstellen
			os.execute("screen -S "..ScreenName.." -L -d -m")
			send_text(msg.to.print_name, "["..botName.."] No shell session found. Creating one...")
			
			if(os.capture("screen -ls "..ScreenName) == NoScreenErrMsg) then -- Noch einmal prüfen ob screen jetzt existiert
				send_text(msg.to.print_name, "["..botName.."] ERROR: Could not create shell session")
				return false
			else
				send_text(msg.to.print_name, "["..botName.."] Shell session ready!")
			end
		end
		
		for k,v in pairs(ActiveUsers) do -- Wenn User bereits in der Shell ist, nichts machen
			if(msg.from.print_name == v) then
				send_text(msg.to.print_name, "["..botName.."] You are already in the interactive shell!")
				return false
			end
		end
		
		table.insert(ActiveUsers, msg.from.print_name) -- User in das Table hinzufügen
		send_text(msg.to.print_name, "["..botName.."] You've entered the interactive shell!")
				
		return true
	else
		return false
	end
end)

addCommand("exit", function(msg,args)
	if(isAdmin(msg)) then
		for k,v in pairs(ActiveUsers) do
			if(msg.from.print_name == v) then
				ActiveUsers[k] = nil -- User aus Table löschen
				send_text(msg.to.print_name, "["..botName.."] You've left the interactive shell.")
				return true
			end
		end
		
		send_text(msg.to.print_name, "["..botName.."] You can't leave the interactive shell because you aren't in there!")
		return false
	else
		return false
	end
end)

hook.Add("tg_MsgReceive", "sendMsgToShell", function(msg)
	if(msg.text ~= nil and string.sub(msg.text,1,1) ~= "!" and string.sub(msg.text,1,1) ~= "/") then -- Wenn es kein Befehl ist
		for k,v in pairs(ActiveUsers) do -- Wenn User in Shell ist, befehl senden
			if(msg.from.print_name == v) then
				lastSize = tonumber(os.capture("stat -c %s "..ScreenLogfile))
				sendCMD(msg.text)
				waitForCommand(msg)
				break
			end
		end
	end
end)

hook.Add("CommandFinished", "WaitForCommand", function(msg) getOutput(msg) end)

function sendCMD(cmd)
	os.execute("screen -S "..ScreenName.." -X stuff '"..cmd.."'^M") -- Befehl an shell screen senden
end

function getOutput(msg)
	local file, errMsg = assert(io.open(ScreenLogfile, "r"))
	if(file == nil) then
		send_text(msg.to.print_name, "["..botName.."] ERROR: Could not open outputfile:\n"..errMsg)
	end
	local fileContent = file:read("*all")
	file:close()
	
	--fileContent = string.sub(fileContent, string.len(msg.text)+1, -3)
	--[[searchString = escape("%$%s"..msg.text)
	sStart, sEnd, sMatch = string.find(fileContent, ".*"..searchString.."(.*)")
	
	if(sStart ~= nil and sEnd ~= nil) then -- Wenn Befehl gefunden wurde
		send_text(msg.to.print_name, string.sub(sMatch,1,-2))
	else
		send_text(msg.to.print_name, "[T-Bot] Empty.")
	end]]
	if(fileContent ~= "" or fileContent ~= nil) then
		send_text(msg.to.print_name, fileContent)
	else
		send_text(msg.to.print_name, "["..botName.."] Empty.")
	end

	eraseFile()
end

--[[function escape(s)
	return (s:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1'):gsub('%z','%%z'))
end]]

function eraseFile()
	file = io.open(ScreenLogfile,"w+")
	io.flush()
	io.close(ScreenLogfile)
end

function waitForCommand(msg) -- Überprüft ob der Befehl schon etwas zurückgegeben hat
	local size = tonumber(os.capture("stat -c %s "..ScreenLogfile))

	if(size > lastSize) then
		hook.Call("CommandFinished", msg)
		hook.Remove("CommandFinished", "WaitForCommand")
		
		lastSize = 0
	else
		postpone(waitForCommand, msg, 1) -- in 1s noch mal prüfen
	end
end