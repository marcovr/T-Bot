-- Countdown Module
seconds = 0
countdownGroup = ""

addCommand("countdown", function(msg, args)
	if(isAdmin(msg)) then
		if(#args == 1) then
	
			if (args[1] == "stop") then
				seconds = 0
			else
				seconds = tonumber(args[1])
				local message = ""
			
				if (seconds ~= nil) then
					message = "["..botName.."] Countdown started\nIt will end in "..seconds.." second(s)"
					countdownGroup = msg.to.print_name
					countdownCheck()
				else
					message = "["..botName.."] Usage: countdown <seconds/stop>"
				end
			
				send_text(msg.to.print_name, message)
			end
		else
			send_text(msg.to.print_name, "["..botName.."] Usage: countdown <seconds/stop>")
		end
	else
		send_text(msg.to.print_name, "["..botName.."] Admin-Only Command")
	end
end)

function countdownCheck()
	if (seconds <= 0) then
		send_text(countdownGroup, "["..botName.."] Countdown ended")
	else
		local sendmsg = false
		if (seconds < 10) then
			sendmsg = true
		elseif (seconds < 60 and seconds % 10 == 0) then
			sendmsg = true
		elseif (seconds < 300 and seconds % 60 == 0) then
			sendmsg = true
		elseif (seconds % 300 == 0) then
			sendmsg = true
		end
		
		if (sendmsg) then
			if (seconds ~= 1) then
				send_text(countdownGroup, "["..botName.."] Countdown: "..seconds.." seconds left")
			else
				send_text(countdownGroup, "["..botName.."] Countdown: "..seconds.." second left")
			end
		end
		
		seconds = seconds - 1
		
		postpone(countdownCheck, false, 1)
	end
end
