--[[ Core module - Docs:
This module provides the most basic set of functions.

ping
	A very simple function to check if the bot is responding.

lua (-x, -f) <cmd/filename>
	Runs a lua script either from given string or file.
	Admin-only command.
	FLAGS
	-x	return output
	-f	load file
	
sh <shellcmd>
	Runs a shell script from given command.
	Admin-only command.
	
ls
	Lists all available chat-commands
	
about
	Displays a short message naming the developers
]]

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
			local func
			local errorStr
			
			-- Analyze flags
			while analyzing do
				analyzing = false
				if string.sub(input, 0, 2) == "-x" then
					input = string.sub(input, 4)
					output = true
					analyzing = true -- continue
				elseif string.sub(input, 0, 2) == "-f" then
					input = string.sub(input, 4)
					file = true
					analyzing = true -- continue
				elseif string.sub(input, 0, 2) == "-E" then
					input = "\"Easter-Eggs are cool!\""
					output = true
					file = false
					-- flag replaces command and overrides other flags
				end
			end
			
			-- load command / file
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
					-- make output more user-friendly
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
			send_text(msg.to.print_name, "["..botName.."] Usage: lua (-x, -f) <cmd/filename>")
		end
	end
end)

addCommand("sh", function(msg, args)
	if(isAdmin(msg)) then
		if(#args > 0) then
			local output = tostring(os.capture(string.sub(msg.text,5), true))
			if(output ~= "") then
				send_text(msg.to.print_name, output)
			else
				send_text(msg.to.print_name, "["..botName.."] [Empty]")
			end
		else
			send_text(msg.to.print_name, "["..botName.."] Usage: sh <shellcmd>")
		end
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