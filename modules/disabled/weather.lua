-- Wetter Modul

addCommand("weather", function(msg,args)
		local ort = "FRIBOURG"
		local ort2 = "Fribourg"
		if(#args == 1) then
			ort = string.upper(args[1])
			ort2 = args[1]
        end
		weather = tostring(os.capture("curl -s 'http://rss.accuweather.com/rss/liveweather_rss.asp?metric=1&locCode=EUR|CH|SZ026|"..ort.."|' | sed -n '/Currently:/ s/.*: \\(.*\\): \\([0-9]*\\)\\([CF]\\).*/\\2°\\3, \\1/p'", true))
		if(weather ~= "") then
			send_text(msg.to.print_name, "["..botName.."] "..ort2..": "..weather)
		else
			send_text(msg.to.print_name, "["..botName.."] "..ort2.." not available")
		end
end)
