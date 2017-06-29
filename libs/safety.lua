local maxOperations = 5e7 -- maximum amount of operations before timeout occurs

--[[ Docs:
This library provides several functions to safely invoke functions.

timeout(function, ...)
	Call function and terminate it if it takes too long.

safeInvoke(function, ...)
	Invoke any function as safe as possible.
	Checks if function exists, then calls it protected and with timeout.

safeCallback(data, success, result)
	Provides a way to safely call callback functions.
	data: Table containing the function [1] and an argument [2]
	Safely invokes function with parameters: argument, success, result.

safePostpone(function, argument, timeout)
	Provides a way to safely postpone function execution by wrapping the function with safeCallback
]]

function timeout(f, ...)
	debug.sethook(function()
		error("timeout", 2)
	end, "", maxOperations)
	local values = {f(...)}
	debug.sethook()
	return table.unpack(values)
end

function safeInvoke(f, ...)
	if type(f) == "function" then
		return pcall(timeout, f, ...)
	else
		return 0, "attempt to call "..type(f)
	end
end

function safeCallback(data, success, result)
	if type(data) == "table" then
		local f = data[1]
		if type(f) == "function" then
			local success, err = pcall(timeout, f, data[2], success, result)
			if not success then
				print("Callback failed: "..err)
			end
		else
			print("Callback failed: attempt to call "..type(f))
		end
	else
		print("Callback failed: no table provided")
	end
end

function safePostpone(f, arg, t)
	postpone(safeCallback, {f, arg}, t)
end