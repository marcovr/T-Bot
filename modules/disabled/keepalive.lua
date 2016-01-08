-- SSH Keepalive module
local ScreenName = "heartbeat"												-- Name des Screens
local NoScreenErrMsg = "No Sockets found in /var/run/screen/S-www-data." 	-- Error welcher kommt, wenn gesuchter Screen nicht gefunden wurde
local hbCMD = 'expect /home/pi/telegram/lua/modules/heartbeat.exp'			-- Heartbeat Befehl

function keepAlive()
	if(os.capture("screen -ls "..ScreenName) == NoScreenErrMsg) then -- Wenn noch kein screen existiert, erstellen
		send_text(mainGroup, "["..botName.."] No heartbeat session found. Creating one...")
		os.execute("screen -S "..ScreenName.." -d -m")
		
		if(os.capture("screen -ls "..ScreenName) == NoScreenErrMsg) then -- Noch einmal prüfen ob screen jetzt existiert
			send_text(mainGroup, "["..botName.."] ERROR: Could not create heartbeat session.")
			return false
		else
			send_text(mainGroup, "["..botName.."] SSH heartbeat online!")
		end
	end
	
	os.execute("screen -S "..ScreenName.." -X stuff '"..hbCMD.."^M'") -- Befehl an shell screen senden
	
	postpone(keepAlive, false, 60)
end

postpone(keepAlive, false, 10)