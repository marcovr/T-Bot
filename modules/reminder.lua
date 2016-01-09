-- Reminder Module
local driver = require "luasql.mysql"
local env = driver.mysql()

local uploader = ""
local downloadFolder = "/home/pi/downloads/"
local lastSize = 0

addCommand("remind", function(msg, args)
	if(#args >= 3) and (#args[1] == 8) and (#args[2] == 5) then
		
		local timestamp = os.time{	year=tonumber(string.sub(args[1],7,8))+2000, 
									month=tonumber(string.sub(args[1],4,5)),
									day=tonumber(string.sub(args[1],1,2)),
									hour=tonumber(string.sub(args[2],1,2)),
									min=tonumber(string.sub(args[2],4,5))}
		
		if(timestamp ~= nil and timestamp > os.time()) then
			local con, err = env:connect("tbot",config.getValue("sqluser"),config.getValue("sqlpw"),"localhost")
			if(con == nil) then
				send_text(msg.to.print_name, "["..botName.."] "..err)
				return false
			end

			local result, err

			if(#args == 3) then
				result, err = con:execute("INSERT INTO reminders (TIME,TARGET,MSG,ATTACHMENT) VALUES ("..timestamp..",'"..msg.to.print_name.."','"..con:escape(args[3]).."','nil')")
			
				con:close()

				if(result == nil) then
					send_text(msg.to.print_name, "["..botName.."] "..err)
				else
					send_text(msg.to.print_name, "["..botName.."] Reminder set.")
				end	
			else
				os.execute("rm -rf /var/www/.telegram-cli/downloads/*")
				uploader = msg.from.print_name
				
				local datatype = args[4]

				hook.Add("tg_MsgReceive", "WaitForFile", function(msg)
				if(msg.text == nil) then	
					if(uploader == msg.from.print_name) then -- Wenn gerade ein Upload erwartet wird und die Nachricht vom Uploader ist
						if(load_document(msg.id, no_sense, false) == true) then
							os.execute("rm -rf /var/www/.telegram-cli/downloads/*")
							postpone(uploading, msg, 3)
							
							hook.Add("DownloadFinished", "WaitForDownload", function(msg)
								os.execute("mv /var/www/.telegram-cli/downloads/download_* "..downloadFolder..msg.id)
		
								if( os.capture('[ -e '..downloadFolder..msg.id..' ] && echo "true" || echo "false"') == "true") then
									send_text(msg.to.print_name, "["..botName.."] Download complete!")
								else
									send_text(msg.to.print_name, "["..botName.."] ERROR: Could not save file.")
								end
							end)
						else
							send_text(msg.to.print_name, "["..botName.."] ERROR: Could not save file.")
						end
						hook.Remove("tg_MsgReceive", "WaitForFile")
						uploader = nil
					end
				end
				end)
				
				local result, err = con:execute("INSERT INTO reminders (TIME,TARGET,MSG,ATTACHMENT) VALUES ("..timestamp..",'"..msg.to.print_name.."','"..con:escape(args[3]).."','"..datatype..":"..downloadFolder..msg.id.."'")
				
				con:close()

				if(result == nil) then
					send_text(msg.to.print_name, "["..botName.."] "..err)
				else
					send_text(msg.to.print_name, "["..botName.."] Reminder set.")
				end
			end
		else
			send_text(msg.to.print_name, "["..botName.."] Invalid time format.")
		end
	else
		send_text(msg.to.print_name, "["..botName.."] Usage: remind <dd.mm.yy> <hh:mm> <\"text\"> [attachment]")
	end
end)

function uploading(msg) -- Überprüft ob file seit letztem mal grösser geworden ist, wenn nicht -> download fertig
	local size = tonumber(os.capture("stat -c %s /var/www/.telegram-cli/downloads/download_*"))

	if(size > lastSize) then
		lastSize = size
		postpone(uploading, msg, 3) -- in 5s noch mal prüfen
	else
		hook.Call("DownloadFinished", msg)
		hook.Remove("DownloadFinished", "WaitForDownload")
		
		lastSize = 0
	end
end

-- function remindercheck wurde ausgelagert nach (/home/pi/remindercheck.lua) und wird mittels cronjob aufgerufen (da postpone unzuverlässig)