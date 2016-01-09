-- Core module
addCommand("ping", function(msg, args)
	send_text(msg.to.print_name, "["..botName.."] Pong!")
end)

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
					elseif output == true then
						output = "[TRUE]"
					elseif output == false then
						output = "[FALSE]"
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

addCommand("ls", function(msg, args)
	local cmds = ""
    for key, value in pairs(chatCommands) do
        if key ~= "getuser" then
            cmds = cmds..key.."\n"
        end
    end
    send_text(msg.to.print_name, "["..botName.."] Available commands:\n"..cmds)
end)

addCommand("about", function (msg, args)
	send_text(msg.to.print_name, "["..botName.."] is being developed by:\n - Marco von Raumer\n - David Enderlin\n - Marcel Schmutz\n©2014") 
end)