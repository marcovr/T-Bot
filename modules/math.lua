-- Math Modul

commands.add("math", function(msg,args)
	if #args > 0 then
		os.execute("rm /tmp/equation.gif") -- aufräumen
		local equation = string.sub(msg.text, 7)
		
		-- Equation formatieren
		equation = equation:gsub("\\", "%%5C")
		equation = equation:gsub("%(", "%%28")
		equation = equation:gsub("%)", "%%29")
		equation = equation:gsub("%>", "%%3E")
		equation = equation:gsub("%<", "%%3C")
		
		os.capture("wget -O /tmp/equation.gif http://latex.codecogs.com/gif.download?%5Cdpi{200}%20"..equation) -- get equation
		
		local f = assert(io.open("/tmp/equation.gif", "r"))
		local t = f:read("*all")
		f:close()
		
		-- Rückmeldung
		if t ~= "Error: Invalid Equation" then
			send_photo(msg.to.print_name, "/tmp/equation.gif" ,void, nil)
		else
			answer(msg, "Error: Invalid Equation")
		end
	else
		answer(msg, "Usage: math <equation>")
	end
end)
