-- Voting Module
local question = ""
local answers = {}
local voters = {}
local votecount = 1

local function s(n)
	return n == 1 and "" or "s"
end

commands.add("startvote", function(msg, args)
	if #args >= 4 then
		-- clearen
		answers = {}
		voters = {}
		
		question = args[1] -- Frage setzen
		votecount = tonumber(args[2]) -- Anzahl Stimmen setzen
		
		table.remove(args, 1) -- Frage aus args table löschen
		table.remove(args, 1) -- Stimmen aus args table löschen
		
		local message = "Vote: \n---- "..question.." ----\n"
		
		for k, v in pairs(args) do
			message = message.."["..k.."] - "..v.."\n"
			local temp = {}
			temp.answer = v
			temp.count = 0
			
			table.insert(answers, temp)
		end
		
		message = message.."Use /vote <index> to vote\nYou have "..votecount.." Vote"..s(votecount)
		
		send(msg.to.print_name, message)
	else
		answer(msg, "Usage: startvote <question> <votecount> <answ1> <answ2> ...")
	end
end, 0)
commands.alias("startvote", "newvote")

commands.add("vote", function(msg, args)
	if #args == 1 then
		local n = tonumber(args[1])
		if n and n > 0 and n <= #answers then
			local name = msg.from.print_name

			if not voters[name] then
				voters[name] = 0
			end
			
			if voters[name] < votecount then
				voters[name] = voters[name] + 1
				answers[n].count = answers[n].count + 1
				answer(msg, "Vote saved")
			else
				answer(msg, "You aren't allowed to vote more than "..votecount.." time"..s(votecount))
			end
		else
			answer(msg, "Usage: vote <index>")
		end
	else
		answer(msg, "Usage: vote <index>")
	end
end)

commands.add("showvote", function(msg, args)
	local message = "Vote: \n---- "..question.." ----\n"
	
	for k, v in pairs(answers) do
		message = message.."["..k.."] - "..v.answer.." - "..v.count.." Vote"..s(v.count).."\n"
	end
	
	send(msg.to.print_name, message)
end)