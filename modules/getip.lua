-- IP Anzeige Modul
domain = "tigerpi.tk"

addCommand("getip", function(msg,args) -- Ist defekt
	if(isAdmin(msg)) then
		outputv4 = tostring(os.capture("curl -s wman197.site40.net/test/ip.php", true))
		outputv6 = tostring(os.capture("curl -s icanhazip.com", true))
		outputTK = tostring(os.capture("ping -c 1 "..domain.." | grep -Eo -m 1 '[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}';"))
		if(output ~= "") then
			local ipv4 = string.match(outputv4, "%?%?(.+)%?%?")
			local uptodate = "false"
			if (outputTK == ipv4) then
				uptodate = "true"
			end
			send_text(msg.to.print_name, "IPv4: http://"..ipv4.."/\nIPv6: http://["..string.sub(outputv6, 1, -2).."]/\nhttp://"..domain.."/ up to date? "..uptodate)
		else
			send_text(msg.to.print_name, "["..botName.."] Empty")
		end
	else
		send_text(msg.to.print_name, "["..botName.."] Admin-Only Command")
	end
end)