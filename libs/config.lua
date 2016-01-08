config = {} -- Table containing the config library

--[[ Docs:
The config library gives you several functions to manage a config file. A config file is useful for storing
sensitive data, if you don't want this data to be in the sourcecode.

config.load()
	Reads the config file and stores it's values into the configValues table.

config.save()
	Saves the content of the configValues table back into the config file.
	
config.getValue(key)
	Returns the value of "key" inside the configValues table.
	
config.setValue(key, value)
	Sets "key" to "value" inside the configValues table and saves the file.
]]

local configValues = {} -- Table containing all the values from the config file

function config.load()
	local file, err = io.open("config.cfg", "r")
	
	if(file ~= nil) then
		for line in file:lines() do
			key = string.match(line, "(.+):")
			value = string.match(line, ":(.+)")
			
			configValues[key] = value
		end
		
		file:close()
	else -- Something went wrong
		send_text(mainGroup, "[T-Bot][Config] Could not open file: " .. err)
	end
end

function config.save()
	local file, err = io.open("config.cfg", "w+")
	
	if(file ~= nil) then
		for k, v in pairs(configValues) do
			file:write(k..":"..v.."\n")
		end
		
		file:flush()
		file:close()
	else -- Something went wrong
		send_text(mainGroup, "[T-Bot][Config] Could not open file: " .. err)
	end
end

function config.setValue(key, value)
	configValues[key] = value -- Set value
	
	config.save()
end

function config.getValue(key)
	for k, v in pairs(configValues) do
		if(k == key) then
			return v
		end
	end
	
	send_text(mainGroup, "[T-Bot][Config] Could not find value of key: " .. key)
end
