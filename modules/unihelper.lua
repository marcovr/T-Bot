-- Timeleft Modul (Titel ist wichtig)

local days = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday"}
local masterTable = {
	{--Marco
		times = {
			{495, 540}, {555, 600}, {615, 660}, {675, 720}, {735, 780}, {795, 840}, {855, 900}, {915, 960}, {975, 1020}, {1035, 1080}, {1095, 1140}
		},
		classes = {
			{""},
			{""},
			{""},
			{""},
			{""}
		}
	},
	{--JJ
		times = {
			{495, 540}, {555, 600}, {615, 660}, {675, 720}, {735, 780}, {795, 840}, {855, 900}, {915, 960}, {975, 1020}, {1035, 1080}, {1095, 1140}
		},
		classes = {
			{""},
			{""},
			{""},
			{""},
			{""}
		}
	},
	{--Dave
		times = {
			{495, 540}, {555, 600}, {615, 660}, {675, 720}, {735, 780}, {795, 840}, {855, 900}, {915, 960}, {975, 1020}
		},
		classes = {
			{""},
			{""},
			{""},
			{""},
			{""}
		}
	},
	{--Schmutz
		times = {
			{495, 540}, {555, 600}, {615, 660}, {675, 720}, {735, 780}, {795, 840}, {855, 900}, {915, 960}, {975, 1020}
		},
		classes = {
			{""},
			{""},
			{""},
			{""},
			{""}
		}
	}
}

addCommand("!", function(msg,arg)
	timeleft(msg,arg)
end )

addCommand("/", function(msg,arg)
	timeleft(msg,arg)
end )

addCommand("tomorrow", function(msg,arg)
	today(msg, 1)
end )

addCommand("today", function(msg,arg)
	today(msg, 0)
end )

addCommand("yesterday", function(msg,arg)
	today(msg, -1)
end )


function today(msg, diff)
	local dateinfo = os.date("*t")
	local day = (dateinfo.wday - 1 + diff)%7
	local name = msg.from.print_name
	local userIndex = getUserIndex(name)
	
	if name=="Marcel_Schmutz" then
		name = "Schmützu"
	elseif name=="David_Enderlin" then
		name = "Dave"
	elseif name=="Johann_Chervet" then
		name = "JJ"
	elseif name=="Marco_von_Raumer" then
		name = "Marco"
	end
	
	if day>5 then --WeekendCheck
		send_text(msg.to.print_name,"It's weekend, "..name)
		return
	end
	
	if userIndex < 1 or userIndex > #masterTable then --UserCheck
		send_text(msg.to.print_name,"I dont't know your timetable, sorry "..name)
		return
	end
	
	-- Los gehts
	
	local times = masterTable[userIndex].times
	local classes = masterTable[userIndex].classes[day]
	local timetable = ""
	
	for i, t in pairs (times) do
		local m1 = t[1] % 60
		local h1 = (t[1] - m1)/60
		local m2 = t[2] % 60
		local h2 = (t[2] - m2)/60
		local class = ""
		if i <= #classes then
			class = classes[i]
		end
		if m1 < 10 then
			m1 = "0"..m1
		end
		if h1 < 10 then
			h1 = "0"..h1
		end
		if m2 < 10 then
			m2 = "0"..m2
		end
		if h2 < 10 then
			h2 = "0"..h2
		end
		
		timetable = timetable.."["..h1..":"..m1.."-"..h2..":"..m2.."] "..class.."\n"
	end
	
	send_text(msg.to.print_name,"Your timetable for "..days[day].." looks like this:\n\n"..timetable)
end

function timeleft(msg,arg)
	local dateinfo = os.date("*t")
	local day = dateinfo.wday - 1
	local timeSec = (((dateinfo.hour*60)+dateinfo.min)*60)+dateinfo.sec
	local name = msg.from.print_name
	local userIndex = getUserIndex(name)

	if name=="Marcel_Schmutz" then
		name = "Schmützu"
	elseif name=="David_Enderlin" then
		name = "Dave"
	elseif name=="Johann_Chervet" then
		name = "JJ"
	elseif name=="Marco_von_Raumer" then
		name = "Marco"
	end
	
	if day>5 then --WeekendCheck
		send_text(msg.to.print_name,"It's weekend, "..name)
		return
	end
	
	if userIndex < 1 or userIndex > #masterTable then --UserCheck
		send_text(msg.to.print_name,"I dont't know your timetable, sorry "..name)
		return
	end
	
	-- Los gehts
	local times = masterTable[userIndex].times
	local classes = masterTable[userIndex].classes[day]
	local currentLesson = "free time"
	local nextLesson = "free time"
	
	if timeSec > times[#classes][2]*60 then
		send_text(msg.to.print_name,"No lessons left today, "..name)
		return
	end
	
	if timeSec < times[1][2]*60 then
		send_text(msg.to.print_name,"Your first lesson ("..classes[1]..") hasn't started yet', "..name)
	end
	
	for i, t in pairs (times) do
		
		if i < #classes then
			if classes[i+1] ~= "" then
				nextLesson = classes[i+1]
			end
		else
			nextLesson = "go home!"
		end
		
		print(t[1]*60, timeSec, t[2]*60)
		
		if timeSec > t[1]*60 and timeSec < t[2]*60 then
			print("yo", i, classes[i])
			if classes[i] ~= "" then
				currentLesson = classes[i]
			end
			
			local timeDiff = (t[2]*60 - timeSec)
			local timeDiffsec = timeDiff % 60
			local timeDiffmin = (timeDiff - timeDiffsec)/60
			
			send_text(msg.to.print_name,"Current Lesson: "..currentLesson.."\nNext Lesson: "..nextLesson.."\nTime left: "..timeDiffmin.." min "..timeDiffsec.." s \n"..name)
			break
		elseif timeSec > t[2]*60 and timeSec < times[i+1][1]*60 then
			currentLesson = "Pause"
			
			local timeDiff = (times[i+1][1]*60 - timeSec)
			local timeDiffsec = timeDiff % 60
			local timeDiffmin = (timeDiff - timeDiffsec)/60
			
			send_text(msg.to.print_name,"Current Lesson: "..currentLesson.."\nNext Lesson: "..nextLesson.."\nTime left: "..timeDiffmin.." min "..timeDiffsec.." s \n"..name)
			break
		end
	end
end

function getUserIndex(name)
	if name=="Marcel_Schmutz" then
		return 4
	elseif name=="David_Enderlin" then
		return 3
	elseif name=="Johann_Chervet" then
		return 2
	elseif name=="Marco_von_Raumer" then
		return 1
	end
end