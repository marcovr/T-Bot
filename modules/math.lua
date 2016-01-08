-- Math Modul

addCommand("math", function(msg,args)
	if(#args > 0) then
		os.execute("rm "..modulePath.."equation.gif")
		local equation = string.sub(msg.text, 7)
		--Eqation formatieren
		
		equation = equation:gsub("\\", "%%5C")
		equation = equation:gsub("%(", "%%28")
		equation = equation:gsub("%)", "%%29")
		equation = equation:gsub("%>", "%%3E")
		equation = equation:gsub("%<", "%%3C")
		
		--send_text(msg.to.print_name, equation)
		
		os.execute("wget -O "..modulePath.."equation.gif http://latex.codecogs.com/gif.download?%5Cdpi{200}%20"..equation)
		
		local f = assert(io.open(modulePath.."equation.gif", "r"))
		local t = f:read("*all")
		f:close()
		
		if(t~="Error: Invalid Equation") then
			send_photo(msg.to.print_name,modulePath.."equation.gif" ,no_sense, false)
		else
			send_text(msg.to.print_name, "["..botName.."] Error: Invalid Equation")
		end
		
	else
		send_text(msg.to.print_name, "["..botName.."] Usage: math <equation>")
	end
end)
