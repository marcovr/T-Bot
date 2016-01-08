-- Timeleft Modul (Titel ist wichtig)
			
					--Zeiten direkt in Min umegerechnet
local Stundenplan 	= {	{485,530},{535,575},{580,625},{640,685},{690,735},{745,790},{795,840},
						{845,890},{895,940},{945,1020}}
local Faecher 		= {	{"Baguette", "Deutsch", "Deutsch", "Philosophie", "Philosophie"},
						{"KLL", "Mathematik", "Baguette", "PAM, Rest nicht wichtig...", "PAM, Rest nicht wichtig..." , "Mittag", "Mittag", "Baguette / Engl. Konversation", "Baguette / Engl. Konversation"},
						{"Philosophie", "Englisch", "Englisch", "PAM, Rest nicht wichtig...", "Mittag", "Mittag", "Geschichte", "Deutsch", "Physik", "Physik"},
						{"Geschichte", "Mathematik", "Mathematik", "Sport", "Sport", "Mittag", "Mittag", "Ergänzungsfach", "Ergänzungsfach"},
						{"Deutsch", "Deutsch", "Baguette", "PAM, Rest nicht wichtig...", "PAM, Rest nicht wichtig...", "Mittag", "Sport", "Mathematik", "Mathematik"}}
local Classes		=	{"Franz", "Deutsch", "Math", "Englisch", "Physik", "Philo", "WiRe", "PAM", "Geschichte", "Info",}

addCommand("!", function(msg,arg)
	timeleft(msg,arg)
end )

addCommand("/", function(msg,arg)
	timeleft(msg,arg)
end )

addCommand("?", function(msg,arg)
	dafuq(msg,arg)
end )

function timeleft(msg,arg)
	local dateinfo=os.date("*t")
	local day=dateinfo.wday-1
	local timeSec=(((dateinfo.hour*60)+dateinfo.min)*60)+dateinfo.sec
	local dayLesson=Faecher[day]
	local name=msg.from.print_name

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
	end
	
	
	for a,b in pairs (Stundenplan) do 
		
		local nextlesson=Stundenplan[a+1]
		local afterSchool=Stundenplan[#dayLesson]
		local preSchool=Stundenplan[1]
		
		if timeSec>afterSchool[2]*60 then --AfterSchoolCheck
			send_text(msg.to.print_name,"School's over go home, "..name)
			break
		end
		
		if a==1 then
			if timeSec<preSchool[1]*60 then --BeforeSchoolCheck
				send_text(msg.to.print_name,"School hasn't started yet, "..name)
				break
			end
		end
		
		

		if timeSec<(nextlesson[1]*60) and timeSec>=(b[2]*60) then --PauseCheck
			local timeDiff=(nextlesson[1]*60)-timeSec
			local timeDiffsec=timeDiff % 60
			local timeDiffmin=(timeDiff-timeDiffsec)/60
			send_text(msg.to.print_name,"Pause...\n"..timeDiffmin.." min "..timeDiffsec.." s ")
			break
		end
		
		local timeDiff=(b[2]*60)-timeSec
		local timeDiffsec=timeDiff % 60
		local timeDiffmin=(timeDiff-timeDiffsec)/60
       local fertig

    if a+1>#dayLesson then
        fertig = "no next lesson"
    else
        fertig = dayLesson[a+1]
    end

		if timeSec>=(b[1]*60) and timeSec<(b[2]*60) then --LessonOutput
			send_text(msg.to.print_name,"Current Lesson: "..dayLesson[a].."\nNext Lesson: "..fertig.."\nTime left: "..timeDiffmin.." min "..timeDiffsec.." s \n"..name)
			break
		end
	end
end


--PruefungsAnzeige
--[[
tests={}

addCommand("addgrade",function(msg,args)
	--if checkArgs(args) then
		--tests[#tests+1]=args[1]
	--end
	tests[1]=args[1]..args[2]..args[3]
	send_text(msg.to.print_name,tests[1])
end)

addCommand("ng", function(msg,args)
	send_text(msg.to.print_name,tests[#tests])
end)
]]--


function checkArgs(a)
	local checkClass=true
	for i=1, #Classes do
		if a[3]~=Classes[i] then
			checkClass=false
		end
	end
	if checkClass==false then 
		send_text(msg.to.print_name, "!!Nicht bekanntes Fach!!")
		return false
	end
	return true
end

function dafuq(msg,arg)
	local name = arg[2]
	if name=="Schmutz" then
			name = "Marcel_Schmutz"
		elseif name=="Dave" then
			name = "David_Enderlin"
		elseif name=="JJ" then
			name = "Johann_Chervet"
		elseif name=="Marco" then
			name = "Marco_von_Raumer"
		end

	local n = arg[1]
	local nachr = arg[3]
	for i=1, n do
		send_text(name, nachr)
	end
end









