-- Voting Module
question = ""
answers = {}
voters = {}
votecount = 1

addCommand("startvote", function(msg, args)
	if(isAdmin(msg)) then
		if(#args >= 4) then
			-- clearen
			answers = {}
			voters = {}
			
			question = args[1] -- Frage setzen
			votecount = tonumber(args[2]) -- Anzahl Stimmen setzen
			table.remove(args,1) -- Frage aus args table löschen
			table.remove(args,1) -- Stimmen aus args table löschen
			
			local message = "["..botName.."] Vote: \n---- "..question.." ----\n"
			
			for k, v in pairs(args) do
				message = message.."["..k.."] - "..v.."\n"
				local temp = {}
				temp.answer = v
				temp.count = 1 --0 ist verboten, sonst tauchen Fehler auf
				
				table.insert(answers, temp)
			end
			
			message = message.."Use /vote <index> to vote\nYou have "..votecount.." Votes"
			
			send_text(msg.to.print_name, message)
		else
			send_text(msg.to.print_name, "["..botName.."] Usage: startvote <question> <votecount> <answ1> <answ2> ...")
		end
	end
end)

addCommand("vote", function(msg, args)
	if(#args == 1) then
		
		local voterid = 1
		local allowedtoVote = false
		local voterExist = false
		for k, v in pairs(voters) do
			if(voters[k].name == msg.from.print_name) then
				voterid = k
				voterExist = true
				break
			end
		end
		
		if voterExist then
			if voters[voterid].votes < votecount then
				voters[voterid].votes = voters[voterid].votes + 1
				allowedtoVote = true
			else
				send_text(msg.to.print_name, "You aren't allowed to vote more than "..votecount.." time(s)")
			end
		else
			local voter = {}
			voter.name = msg.from.print_name
			voter.votes = 1
			
			table.insert(voters, voter)
			allowedtoVote = true
		end
		
		if allowedtoVote then
			answers[tonumber(args[1])].count = answers[tonumber(args[1])].count + 1
			
			--[[local message = "["..botName.."] Vote: \n---- "..question.." ----\n"
			for k, v in pairs(answers) do
				message = message.."["..k.."] - "..v.answer.." - "..(v.count - 1).." Votes\n"
			end
			
			send_text(msg.to.print_name, message)--]]
		end
	else
		send_text(msg.to.print_name, "["..botName.."] Usage: vote <index>")
	end
end)

addCommand("showvote", function(msg, args)
	local message = "["..botName.."] Vote: \n---- "..question.." ----\n"
	
	for k, v in pairs(answers) do
		message = message.."["..k.."] - "..v.answer.." - "..(v.count - 1).." Vote(s)\n"
	end
	
	send_text(msg.to.print_name, message)
end)