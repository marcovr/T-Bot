--[[ Core module - Docs:
This module provides the most basic set of functions.

update
	forces a git reset and then updates

reload
	reloads the whole bot

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

------ Vital chat commands ------
commands.add("update", function(msg, args)
	--[[os.capture("cd "..installPath.." && git reset --hard")
	local text = os.capture("cd "..installPath.." && git pull")
	if text ~= "Already up-to-date." then
		local beginPos, endPos, fromVersion, toVersion = string.find(text, "(%w+)%.%.(%w+)") 	-- Get version hashes
		text = string.sub(text, endPos+15)														-- Remove version hashes from string
		text = string.gsub(text, "([%+%-]+)%s", "%1\n")											-- Format file changes
		send(msg.to.print_name, [Update] Updating from <"..fromVersion.."> to <"..toVersion..">\n"..text)
		postpone(chatCommands.reload, {from={print_name="T-Bot"}}, 1)							-- Safety delay to give the update process some time (needs admin credentials)
	else
		answer(msg, [Update] Already up-to-date.")
	end]]--
	answer(msg, "[Update] function currently disabled.")
end, 10)

commands.add("reload", function(msg, args)
	local func, err = loadfile(defaultFilePath)
	if func then
		local success, err = pcall(func)
		if not success then
			print("Error running main file:\n"..err)
		end
	else
		print("Error reloading main file:\n"..err)
	end
end, 10)

commands.add("ping", function(msg, args)
	answer(msg, "Pong!")
end)

commands.add("lua", function(msg, args)
	if #args > 0 then
		local input = string.sub(msg.text,6)
		local output = false
		local file = false
		local analyzing = true
		
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
		local func, err
		if file then
			func, err = loadfile(input) -- 
		elseif output then
			input = "return "..input
			func, err = loadstring(input) --
		else
			func, err = loadstring(input) --
		end
		
		if func then
			local success, out = safeInvoke(func)
			if not success then
				answer(msg, "Lua Error: "..out)
			elseif output then
				answer(msg, stringify(out))
			end
		else
			answer(msg, "Parse Error: "..err)
		end
	else
		answer(msg, "Usage: lua (-x, -f) <cmd/filename>")
	end
end, math.huge)

commands.add("sh", function(msg, args)
	if #args > 0 then
		local output = os.capture(string.sub(msg.text,5), true)
		if output ~= "" then
			answer(msg, output)
		else
			answer(msg, "[Empty]")
		end
	else
		answer(msg, "Usage: sh <shellcmd>")
	end
end, math.huge)

commands.add("ls", function(msg, args)
	answer(msg, "Available commands:\n"..commands.list())
end)

commands.add("about", function (msg, args)
	answer(msg, "T-Bot is being developed by:\n - Marco von Raumer\n - David Enderlin\n - Marcel Schmutz\n©2014") 
end)

commands.add("error", function(msg, args)
	error("error")
end, 0)