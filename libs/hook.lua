hook = {}	-- Table containing the hook library

--[[ Docs:
The hook library gives you several functions to easily manage and implement events. You can "hook" functions
to an event and whenever that event gets called, all the hooked functions will be executed.

hook.add(eventName, identifier, func)
	Hooks the given function "func" to the event "eventName".
	The identifier is a name or something describing the hook, so you can identify it later.
	Returns true if successful.

hook.remove(eventName, identifier)
	Removes the hook "identifier" from the event "eventName".
	Returns true if successful.

hook.call(eventName, ...)
	Tries to call the given hook "eventName" executing all associated functions with the given arguments.

hook.getTable()
	Returns the hook table containing all hooks.
]]

local hookTable = {} -- Table containing all hooks

function hook.add(eventName, identifier, func)
	if not hookTable[eventName] then -- Add new event if not yet existing
		hookTable[eventName] = {}
	end
	
	if hookTable[eventName][identifier] then -- Don't add a new hook if there is already one with the same identifier
		return false
	end
	
	hookTable[eventName][identifier] = func -- Set hook
	
	return true
end

function hook.remove(eventName, identifier)
	if hookTable[eventName] then
		hookTable[eventName][identifier] = nil
		return true
	end
	
	return false
end

function hook.call(eventName, ...)
	if not hookTable[eventName] then -- Add new event if not yet existing
		hookTable[eventName] = {}
		return true
	end
	
	for k in pairs(hookTable[eventName]) do
		hookTable[eventName][k](...)
	end
	
	return true
end

function hook.getTable()
	return hookTable
end