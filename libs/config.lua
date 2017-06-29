config = {} -- Table containing the config library

--[[ Docs:
The config library gives you several functions to manage a config file. A config file is useful for storing
sensitive data, if you don't want this data to be in the sourcecode.

config.load()
	Reads the config file and stores it's values into the configValues table.

config.save()
	Saves the content of the configValues table back into the config file.

config.get(key)
	Returns the value of "key" inside the configValues table.

config.set(key, value)
	Sets "key" to "value" inside the configValues table and saves the file.
]]

local configValues = {} -- Table containing all the values from the config file
local configFile = "config.cfg"

function config.load()
	local file, err = io.open(configFile, "r")
	
	if file then
		local line = file:read()
	
		while line do
			local key = string.match(line, "(.+):")
			local value = string.match(line, ":(.+)")
			
			configValues[key] = value
			
			line = file:read()
		end
		
		file:close()
	else -- Something went wrong
		log("[Config] Could not open file: "..err)
	end
end

function config.save()
	local file, err = io.open(configFile, "w+")
	
	if file then
		for k, v in pairs(configValues) do
			file:write(k..":"..v.."\n")
		end
		
		file:flush()
		file:close()
	else -- Something went wrong
		log("[Config] Could not open file: "..err)
	end
end

function config.set(key, value)
	configValues[key] = value -- Set value
	
	config.save()
end

function config.get(key)
	return configValues[key]
end
