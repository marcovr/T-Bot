local timegrid = {	{{8,5},{8,50}},{{8,55},{9,35}},{{9,40},{10,25}},{{10,40},{11,25}},{{11,30},{12,15}},{{12,25},{13,10}},{{13,15},{14,0}},
					{{14,5},{14,50}},{{14,55},{15,40}},{{15,45},{16,30}}}
local subjects = {	{"Französisch", "Deutsch", "Deutsch", "Philosophie", "Philosophie"},
					{"KLL", "Mathematik", "Französisch", "Schwerpunktfach", "Schwerpunktfach" , "", "", "Frz. / Engl. Konversation", "Frz. / Engl. Konversation"},
					{"Philosophie", "Englisch", "Englisch", "Schwerpunktfach", "", "", "Geschichte", "Deutsch", "Physik", "Physik"},
					{"Geschichte", "Mathematik", "Mathematik", "Sport", "Sport", "", "", "Ergänzungsfach", "Ergänzungsfach"},
					{"Deutsch", "Deutsch", "Französisch", "Schwerpunktfach", "Schwerpunktfach", "", "Sport", "Mathematik", "Mathematik"}}
					
addCommand("timeleft", function(msg, args)
	local curTime = os.date("*t")
	local curDay = curTime.wday-1
	
	local lastLesson = timegrid[#subjects[curDay]] -- Letzte Stunde des Tages bekommen
		
	if(encodeTime(getHourTable(curTime)) > encodeTime(lastLesson[2])) then -- Wenn man schon nach der letzten Stunde ist
		send_text(msg.to.print_name, "["..botName.."] Schoolhelper:\nSchool is over - go home!")
	elseif(encodeTime(getHourTable(curTime)) < encodeTime(timegrid[1][1])) then -- Wenn man vor der ersten Stunde ist
		send_text(msg.to.print_name, "["..botName.."] Schoolhelper:\nSchool did not start yet.\nI suggest to do the homework for the first lesson now!")
	else
		for k, v in pairs(timegrid) do
			if(encodeTime(getHourTable(curTime)) > encodeTime(v[1]) and encodeTime(getHourTable(curTime)) < encodeTime(v[2])) then -- Wenn man während einer Stunde ist
				local lastLessonInRow = k
				for i=k, #subjects[curDay], 1 do -- Letzte Stunde in einer Reihe erkennen
					if(subjects[curDay][lastLessonInRow] == subjects[curDay][i]) then
						lastLessonInRow = i
					end
				end
				
				local nextTime = getTimeUntilNextLesson(timegrid[lastLessonInRow][2])
				send_text(msg.to.print_name, "["..botName.."] Schoolhelper:\nCurrent lesson: "..subjects[curDay][k].."\nTime until lesson ends: "..nextTime[1].."h "..nextTime[2].."m "..nextTime[3].."s\nNext lesson: "..subjects[curDay][lastLessonInRow+1])
				break
			elseif(encodeTime(getHourTable(curTime)) > encodeTime(v[2]) and encodeTime(getHourTable(curTime)) < encodeTime(timegrid[k+1][1])) then -- Wenn man zwischen zwei Stunden ist
				if(subjects[curDay][k+1] == "") then
					local lastLessonInRow = k+1
					for i=k+1, #subjects[curDay], 1 do -- Letzte Stunde in einer Reihe erkennen
						if(subjects[curDay][lastLessonInRow] == subjects[curDay][i]) then
							lastLessonInRow = i
						end
					end
					local nextTime = getTimeUntilNextLesson(timegrid[lastLessonInRow][2])
				end
				
				local nextTime = getTimeUntilNextLesson(timegrid[k+1][1])
				send_text(msg.to.print_name, "["..botName.."] Schoolhelper:\nCurrent lesson: Pause\nTime until lesson ends: "..nextTime[1].."h "..nextTime[2].."m "..nextTime[3].."s\nNext lesson: "..subjects[curDay][k+1])
				break
			end
		end
	end
end)

function encodeTime(hourTable)
	return hourTable[1]*60+hourTable[2] -- In Minuten umrechnen
end

function getHourTable(timeTable)
	local hTable = {timeTable.hour, timeTable.min}
	
	return hTable
end

function getTimeUntilNextLesson(targetTimeTable)
	local curTime = os.date("*t")
	
	local targetTime = targetTimeTable[1]*3600+targetTimeTable[2]*60 -- In Sekunden umrechnen
	local currentTime = curTime.hour*3600+curTime.min*60+curTime.sec
	
	local timeDiff = targetTime-currentTime
	
	local timeDiffTable = {}
	local remainder = 0
	
	timeDiffTable[1] = math.floor(timeDiff/3600)
	remainder = timeDiff%3600
	
	timeDiffTable[2] = math.floor(remainder/60)
	remainder = remainder%60
	
	timeDiffTable[3] = math.floor(remainder)
	
	return timeDiffTable
end