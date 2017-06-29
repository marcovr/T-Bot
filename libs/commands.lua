commands = {} -- Table containing the commands library

--[[ Docs:
The commands library handles everything concerning chat commands.

commands.add(command, func [, level])
	Adds a new chat command that calls func upon execution.
	Optional: a minimal permission level needed.

commands.alias(command, command2)
	Creates an alias for command.

commands.list()
	Returns the sorted list of all commands as string.

commands.handle(msg)
	Treats the message and executes the found command (if any).

commands.getTable()
	Returns the table containing all commands.
]]

local chatCommands = {}

function commands.add(command, func, level)
	chatCommands[command] = {["func"] = func, ["level"] = level}
end

function commands.alias(command, command2)
	chatCommands[command2] = chatCommands[command]
end

function commands.list()
	local cmds = {}
	for k in pairs(chatCommands) do
		table.insert(cmds, k)
	end
	table.sort(cmds)
	return table.concat(cmds, "\n")
end

function commands.handle(msg)
	mark_read(msg.to.print_name, void, nil)
	
	local text = string.sub(msg.text, 2)			
	local command = string.lower(string.match(text, "%S+"))
	local cmd = chatCommands[command]
	
	if not cmd then
		answer(msg, "Unknown command")
		return
	end
	
	if cmd.level then
		local level = permissions.get(msg.from.print_name)
		if not level then
			answer(msg, "Command only available for authorized users")
			return
		elseif level < cmd.level then
			answer(msg, "Current access level ["..level.."] insufficient for this command")
			return
		end
	end
		
	local success, args = getArguments(text)

	if success or command == "lua" or command == "luas" or command == "sh" then -- Lua and Shell command should ignore quotes
		local success, err = safeInvoke(cmd.func, msg, args)
		if not success then
			answer(msg, "Command Error: "..err)
		end
	else
		answer(msg, "Error: unbalanced quotes!")
	end
end

function commands.getTable()
	return chatCommands
end