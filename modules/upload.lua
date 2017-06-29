-- File Uploading Module
local uploader = ""
local targetFileName = ""
local lastSize = 0
local uploading
local downloadDir = "/home/pi/.telegram-cli/downloads/"

commands.add("uploadfile", function(msg, args)
	if #args == 1 then
		uploader = msg.from.print_name
		targetFileName = args[1]
		
		answer(msg, "Waiting for file...")
		
		hook.add("tg_MsgReceive", "CheckForFile", function(msg)
			if not msg.media or msg.media.type ~= "document" then
				return -- no file found yet
			end
			if uploader == msg.from.print_name then -- Wenn gerade ein Upload erwartet wird und die Nachricht vom Uploader ist
				os.execute("rm "..downloadDir.."download_*")
				
				if load_document(msg.id, void, nil) then
					answer(msg, "File found, downloading...")
					safePostpone(uploading, msg, 3)
					
					hook.add("DownloadFinished", "WaitForDownload", function(msg)
						os.execute("mv "..downloadDir.."download_* "..targetFileName)

						if os.capture('[ -e '..targetFileName..' ] && echo "true" || echo "false"') == "true" then
							answer(msg, "Download complete!")
						else
							answer(msg, "Error: Could not save file.")
						end
						
						targetFileName = ""
					end)
				else
					answer(msg, "Error: Could not save file.")
				end
				hook.remove("tg_MsgReceive", "CheckForFile")
				uploader = nil
			end
		end)
	else
		answer(msg, "Usage: uploadfile <targetFile>")
	end
end, math.huge)
commands.alias("uploadfile", "upload")

commands.add("luau", function(msg, args)
	uploader = msg.from.print_name
	
	answer(msg, "Waiting for executable lua script...")
	
	hook.add("tg_MsgReceive", "CheckForFile", function(msg)
		if not msg.media or msg.media.type ~= "document" then
			return -- no file found yet
		end	
		if uploader == msg.from.print_name then -- Wenn gerade ein Upload erwartet wird und die Nachricht vom Uploader ist
			os.execute("rm "..downloadDir.."download_*")
			
			if load_document(msg.id, void, nil) then
				answer(msg, "File found, downloading...")
				safePostpone(uploading, msg, 3)
				
				hook.add("DownloadFinished", "WaitForDownload", function(msg)
					local filename = os.capture("ls "..downloadDir.."download_*")
					
					local func, errorStr = loadfile(filename) 
					if func then
						local success, errorStr = pcall(func)
						if not success then
							answer(msg, "Lua Error: "..errorStr)
						end
					else
						answer(msg, "Parse Error: "..errorStr)
					end
					
					os.execute("rm "..filename)
				end)
			else
				answer(msg, "Error: Could not save file.")
			end
			
			hook.remove("tg_MsgReceive", "CheckForFile")
			uploader = nil
		end
	end)
end, math.huge)

function uploading(msg) -- Überprüft ob file seit letztem mal grösser geworden ist, wenn nicht -> download fertig
	local size = tonumber(os.capture("stat -c %s "..downloadDir.."download_*"))

	if size and size > lastSize then
		lastSize = size
		safePostpone(uploading, msg, 3) -- in 5s noch mal prüfen
	else
		hook.call("DownloadFinished", msg)
		hook.remove("DownloadFinished", "WaitForDownload")
		
		lastSize = 0
	end
end