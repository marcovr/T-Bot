-- File Uploading Module
local uploader = ""
local targetFileName = ""
local downloadFolder = "/home/pi/downloads/"
local lastSize = 0

addCommand("uploadfile", function(msg, args)
	if(isAdmin(msg)) then
		if(#args == 1) then
			uploader = msg.from.print_name
			targetFileName = args[1]
			
			send_text(msg.to.print_name, "["..botName.."] Waiting for file...")
			
			hook.Add("tg_MsgReceive", "CheckForFile", function(msg)
				if(msg.text == nil) then	
					if(uploader == msg.from.print_name) then -- Wenn gerade ein Upload erwartet wird und die Nachricht vom Uploader ist
						if(load_document(msg.id, no_sense, false) == true) then
							send_text(msg.to.print_name, "["..botName.."] File found, downloading...")
							postpone(uploading, msg, 3)
							
							hook.Add("DownloadFinished", "WaitForDownload", function(msg)
								os.capture("mv /var/www/.telegram-cli/downloads/download_* "..downloadFolder..targetFileName)
		
								if( os.capture('[ -e '..downloadFolder..targetFileName..' ] && echo "true" || echo "false"') == "true") then
									send_text(msg.to.print_name, "["..botName.."] Download complete!")
								else
									send_text(msg.to.print_name, "["..botName.."] ERROR: Could not save file.")
								end
								
								targetFileName = ""
							end)
						else
							send_text(msg.to.print_name, "["..botName.."] ERROR: Could not save file.")
						end
						hook.Remove("tg_MsgReceive", "CheckForFile")
						uploader = nil
					end
				end
			end)
		else
			send_text(msg.to.print_name, "["..botName.."] Usage: uploadfile <targetFileName>")
		end
	else
		send_text(msg.to.print_name, "["..botName.."] Admin-Only Command")
	end
end)

addCommand("luau", function(msg, args)
	if(isAdmin(msg)) then
		uploader = msg.from.print_name
		
		send_text(msg.to.print_name, "["..botName.."] Waiting for executable lua script...")
		
		hook.Add("tg_MsgReceive", "CheckForFile", function(msg)
			if(msg.text == nil) then	
				if(uploader == msg.from.print_name) then -- Wenn gerade ein Upload erwartet wird und die Nachricht vom Uploader ist
					if(load_document(msg.id, no_sense, false) == true) then
						send_text(msg.to.print_name, "["..botName.."] File found, downloading...")
						postpone(uploading, msg, 3)
						
						hook.Add("DownloadFinished", "WaitForDownload", function(msg)
							filename = tostring(os.capture("ls /var/www/.telegram-cli/downloads/download_*", false))
	
							func, errorStr = loadfile(filename) 
							if(func == nil) then
								send_text(msg.to.print_name, "["..botName.."] An error occured while running the script:\n"..errorStr)
							else
								func()
							end
							
							os.execute("rm "..filename)
						end)
					else
						send_text(msg.to.print_name, "["..botName.."] ERROR: Could not save file.")
					end
					
					hook.Remove("tg_MsgReceive", "CheckForFile")
					uploader = nil
				end
			end
		end)
	else
		send_text(msg.to.print_name, "["..botName.."] Admin-Only Command")
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