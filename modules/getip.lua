-- IP Anzeige Modul
local domain = "tigerpi.tk"

commands.add("getip", function(msg,args) -- Ist defekt
	local outputv4 = tostring(os.capture("curl -s wman197.site40.net/test/ip.php", true))
	local outputv6 = tostring(os.capture("curl -s icanhazip.com", true))
	local outputTK = tostring(os.capture("ping -c 1 "..domain.." | grep -Eo -m 1 '[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}';"))
	if outputv4 and outputv4 ~= "" then
		local ipv4 = string.match(outputv4, "%?%?(.+)%?%?")
		local uptodate = "false"
		if outputTK == ipv4 then
			uptodate = "true"
		end
		answer(msg, "IPv4: http://"..ipv4.."/\nIPv6: http://["..string.sub(outputv6, 1, -2).."]/\nhttp://"..domain.."/ up to date? "..uptodate)
	else
		answer(msg, "Empty")
	end
end, 5)