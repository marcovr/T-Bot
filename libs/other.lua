--[[ Docs:
This library is just a random collection of functions which don't fit into another library.

table.deepcopy(variable)
	Makes a true copy (not just a reference) of a given variable.

table.show(table)
	Returns a readable representation of a table as string.

stringify(...)
	Like to tostring() but supports multiple arguments and displays tables.

getArguments(text)
	Returns a table of arguments extracted from text.
]]

function table.deepcopy(orig)
	if type(orig) == 'table' then
		local copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[table.deepcopy(orig_key)] = table.deepcopy(orig_value)
		end
		setmetatable(copy, table.deepcopy(getmetatable(orig)))
		return copy
	else -- number, string, boolean, etc
		return orig
	end
end

function table.show(tbl, i, seen)
	if not seen then
		seen = {}
		seen[seen] = true
	end
	if not i then
		i = ""
	end
	local text = "{\n"
	local s={}
	local i2 = i.."\t"
	seen[tbl]=true
	
	for k in pairs(tbl) do
		table.insert(s, k)
	end
	table.sort(s)
	for k,v in ipairs(s) do
		text = text..i2..tostring(v)
		v = tbl[v]
		
		if type(v) == "function" then
			text = text.."()\n"
		elseif type(v) == "table" and not seen[v] then
			text = text.." = "..table.show(v, i2, seen).."\n"
		else
			text = text.." = "..tostring(v).."\n"
		end
	end
	return text..i .."}"
end

function stringify(...)
	local args = {...}
	
	local n = select("#", ...)
	
	for i = 1, n do
		if type(args[i]) == "table" then
			args[i] = table.show(args[i])
		else
			args[i] = tostring(args[i])
		end
	end	
	return table.concat(args, " ")
end

function getArguments(text)
	local words = {}
	for word in string.gmatch(string.sub(text, 2), "%S+") do
		table.insert(words, word)
	end
	
	local args = {}
	local quoteClosed = true
	local skip = 2
	
	for k = 2, #words do -- Quotes parsen
		if k >= skip then
			local word = words[k]
			if string.sub(word, -1) == "\"" and string.sub(word, 1, 1) == "\"" then -- Wenn Anfangsquote auch Endquote ist
				table.insert(args, string.sub(word, 2, -2))
			elseif string.sub(word, 1, 1) == "\"" then -- Wenn Anfangsquote gefunden wurde
				quoteClosed = false
				for i = k + 1, #words do -- Durch alle restlichen Argumente gehen und Endquote suchen
					if string.sub(words[i], -1) == "\"" then -- Wenn Endquote gefunden wurde
						quoteClosed = true -- Quote wurde geschlossen
						local arg = string.sub(word, 2) -- Argument mit Anfangsquote zu arg hinzufügen
						for j = k + 1, i - 1 do -- Von Anfangs+1 bis Endquote-1 durchgehen
							arg = arg.." "..words[j] -- Argumente zwischen Anfangs und Endquote zu arg hinzufügen
						end
						arg = arg.." "..string.sub(words[i], 1, -2) -- Argument mit Endquote zu arg hinzufügen
						skip = i + 1 -- Bis nach die Quote skippen
						table.insert(args, arg) -- arg in neues Argument-Table hinzufügen
						break
					end
				end
			else
				table.insert(args, word)
			end
		end
	end
	
	return quoteClosed, args
end