-- MySQL Module
local driver = require "luasql.mysql"
local env = driver.mysql()

addCommand("sql", function(msg,args)
	if(isAdmin(msg)) then
		if(#args == 2) then
			local con, err = env:connect(args[1], config.getValue("sqluser"),config.getValue("sqlpw"),"localhost")
			if(con == nil) then
				send_text(msg.to.print_name, "["..botName.."] "..err)
				return false
			end
			local result, err = con:execute(args[2])
			con:close()
			if(result ~= nil) then
				local temp = {}
				while(result:fetch(temp, "a") ~= nil) do 
					send_text(msg.to.print_name, "["..botName.."] MySQL Answer:\n"..table.show(temp))
				end
				result:close()
			else
				send_text(msg.to.print_name, "["..botName.."] "..err)
			end
		else
			send_text(msg.to.print_name, "["..botName.."] Usage: sql <db> <statement>")
		end
	end
end)

addCommand("getuser", function(msg, args)
	if(msg.to.print_name == "Tiger_Tiger" or msg.to.print_name == "M-Bot_Dev_Chat") then -- Befehl auf Tiger_Tiger Gruppe begrenzen
		if(isAdmin(msg)) then
			if(#args > 0) then
				local con, err = env:connect("maclog_data",config.getValue("sqluser"),config.getValue("sqlpw"),"localhost")
				if(con == nil) then
					send_text(msg.to.print_name, "["..botName.."] "..err)
					return false
				end
				local result, err = con:execute("SELECT Id,User FROM userids WHERE locate('"..args[1].."',User)>0;")
				local hits = 0
				if(result ~= nil) then
					local temp = {}
					temp[0] = {}
					while(result:fetch(temp[hits], "a") ~= nil) do 
						hits = hits + 1
						temp[hits] = {}
					end
					result:close()

					if (hits > 1) then
						local answ = "["..botName.."] got multiple results - please specify:\n"
						for i = 0, hits - 1, 1 do
							answ = answ.." -> "..temp[i]["User"].."\n"
						end
						send_text(msg.to.print_name, answ)
					elseif (hits == 1) then
						local result, err = con:execute("SELECT * FROM userdata WHERE Id='"..temp[0]["Id"].."';")
						local answ = "["..botName.."] Found userdata:\n"
						local temp = {}
						while(result:fetch(temp, "a") ~= nil) do
							answ = answ..temp["Account"]..': "'..temp["Username"]..'" / "'..temp["Password"]..'"\n'
						end
						send_text(msg.to.print_name, answ)
					else
						local result, err = con:execute("SELECT * FROM userdata WHERE locate('"..args[1].."',Username)>0;")
						local answ = "["..botName.."] Found userdata:\n"
						local temp = {}
						while(result:fetch(temp, "a") ~= nil) do
							answ = answ..temp["Account"]..': "'..temp["Username"]..'" / "'..temp["Password"]..'"\n'
						end
						send_text(msg.to.print_name, answ)
					end
					con:close()
				else
					send_text(msg.to.print_name, "["..botName.."] "..err)
				end
			else
				send_text(msg.to.print_name, "["..botName.."] Usage: getuser <searchterm>")
			end
		end
	else
		send_text(msg.to.print_name, "["..botName.."] Unknown command")
	end
end)