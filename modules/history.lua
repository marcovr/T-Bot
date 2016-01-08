-- History Module

local upperlimit = 100000
local topusers

addCommand("history", function(msg,args)
	local cb_extra = {}
	
	if(#args == 2) then
		cb_extra.target = msg.to.print_name
		cb_extra.count = tonumber(args[2])
		
		get_history(msg.to.print_name, tonumber(args[1]), tonumber(args[2]), history_cb, cb_extra)
	elseif(#args == 3) then
		cb_extra.target = msg.to.print_name
		cb_extra.count = tonumber(args[2])
		
		get_history(args[3], tonumber(args[1]), tonumber(args[2]), history_cb, cb_extra)
	else
		send_text(msg.to.print_name, "["..botName.."] Usage: history <offset> <count> [peer]")
	end
end)

function history_cb(extra, success, result)
	local text = ""
	for i=0, extra.count-1 do
		msg = result[i]
		if (msg ~= nil and msg.text ~= nil) then
			text = text .. msg.from.print_name .. ": " .. msg.text .. "\n"
		else
			text = text .. "inexistant message\n"
		end
	end
	send_text(extra.target, "History:\n" .. text)
end

addCommand("msgcount", function(msg,args)
	if(#args < 2) then
		local cb_extra = {}
		cb_extra.upperlimit = upperlimit
		cb_extra.probevalue = upperlimit
		cb_extra.lowerlimit = 0
		cb_extra.target = msg.to.print_name
		
		if(#args == 0) then
			cb_extra.peer = msg.to.print_name
		elseif(#args == 1) then
			cb_extra.peer = args[1]
		end
		
		get_history(cb_extra.peer, upperlimit, 1, msgcount_cb, cb_extra)
	else
		send_text(msg.to.print_name, "["..botName.."] Usage: msgcount [peer]")
	end
end)

function msgcount_cb(extra, success, result)
	if (result[0] ~= nil) then
		extra.lowerlimit = extra.probevalue
	else
		extra.upperlimit = extra.probevalue
	end
	
	extra.probevalue = math.floor((extra.upperlimit + extra.lowerlimit)/2)
	
	if extra.probevalue == extra.lowerlimit then
		send_text(extra.target, "Message count: " .. extra.probevalue)
	else
		get_history(extra.peer, extra.probevalue, 1, msgcount_cb, extra)
	end
end

-- WIP
addCommand("wordcount", function(msg,args)
	local cb_extra = {}
	
	if(#args == 2) then
		cb_extra.target = msg.to.print_name
		cb_extra.word = args[1]
		
		get_history(msg.to.print_name, tonumber(args[2]), wordcount_cb, cb_extra)
		
		send_text(msg.to.print_name, "["..botName.."] retrieving wordcount of " .. msg.to.print_name .. "...")
	elseif(#args == 3) then
		cb_extra.target = msg.to.print_name
		cb_extra.word = args[1]
		
		get_history(args[3], tonumber(args[2]), wordcount_cb, cb_extra)
		
		send_text(msg.to.print_name, "["..botName.."] retrieving wordcount of " .. args[3] .. "...")
	else
		send_text(msg.to.print_name, "["..botName.."] Usage: wordcount <word> <count> [peer]")
	end
end)

function wordcount_cb(extra, success, result)
	local text = ""
	local wordcount = 0
	for i,msg in pairs (result) do
		if(msg.text ~= nil) then
			for word in string.gmatch(" "..string.lower(msg.text).." ", "[%c%s]".. extra.word .."[%c%s]") do
				wordcount = wordcount + 1
			end
		end
	end
	send_text(extra.target, "wordcount of ".. extra.word ..": " .. wordcount)
end


addCommand("topusers", function(msg,args)
	if(#args < 2) then
		local cb_extra = {}
		local last
		cb_extra.target = msg.to.print_name
		cb_extra.step = 1000
		topusers = {}
		
		if(#args == 0) then
			cb_extra.peer = msg.to.print_name
		elseif(#args == 1) then
			cb_extra.peer = args[1]
		end
		
		local msgcount = 20000 --WIP
		cb_extra.offset = msgcount-cb_extra.step
		
		get_history(cb_extra.peer, cb_extra.offset, cb_extra.step, topusers_cb, cb_extra)
	else
		send_text(msg.to.print_name, "["..botName.."] Usage: topusers [peer]")
	end
end)

function topusers_cb(extra, success, result)
	print(extra.offset)
	for i=0, #result-1 do
		msg = result[i]
		if (msg ~= nil and msg.from ~= nil and msg.from.print_name ~= nil) then
			if (topusers[msg.from.print_name] ~= nil) then
				topusers[msg.from.print_name] =  topusers[msg.from.print_name] + 1
			else
				topusers[msg.from.print_name] = 1
			end
		end
	end
	
	if (extra.offset > 0) then
		extra.offset = extra.offset - extra.step
		if (extra.offset < 0) then
			extra.offset = 0
		end
		postpone(postpone_history_cb, extra, 10)
		--get_history(extra.peer, extra.offset, extra.step, topusers_cb, extra)
	else
		print("end")
		local text = ""
		for name,value in pairs (topusers) do 
			text = text .. name .. ": " .. value .. " messages\n"
		end
		send_text(extra.target, "Top users of ".. extra.peer ..":\n" .. text)
	end
end

function postpone_history_cb(extra, success, result)
	get_history(extra.peer, extra.offset, extra.step, topusers_cb, extra)
end