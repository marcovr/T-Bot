-- Troll Modul

addCommand("troll", function(msg,args)
		local who = msg.to.print_name
		if(#args == 1) then
			who = args[1]
		end
		send_document(who,"/home/pi/Trollface.webp", no_sense, false)
end)
