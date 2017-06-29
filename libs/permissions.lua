permissions = {} -- Table containing the permissions library

--[[ Docs:
The permissions library can be used to easily manage user permission levels for commands.

permissions.set(name, level)
	Sets the permission level of the given user.

permissions.get(name)
	Returns the permission level of the given user.

permissions.getTable()
	Returns the table containing all permissions.
]]

-- Predefine max permission level for bot itself
local users = {[botName] = math.huge}

function permissions.set(name, level)
	users[name] = level
end

function permissions.get(name)
	return users[name]
end

function permissions.getTable()
	return users
end