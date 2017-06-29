--[[ Spam module - Docs:
spam <peer> <number>
	Spams people.
	
delete as reply to message
	deletes all messages until replied message
]]

local spam = {}

commands.add("spam", function(msg, args)
	if #args > 1 then
		local n = tonumber(args[2])
		if n then
			if n > 50 then
				n = 50
			end
			local data = {}
			data.target = args[1]
			data.count = n
			spam.spam(data)
		else
			answer(msg, "Usage: spam <peer> <number>")
		end
	else
		answer(msg, "Usage: spam <peer> <number>")
	end
end, 0)

commands.add("delete", function(msg, args)
	if msg.reply_id then
		local data = {peer = msg.to.print_name, id = msg.reply_id, count = 0, f = spam.history_delete}
		get_history(data.peer, 0, 10, safeCallback, {data.f, data})
	else
		answer(msg, "Usage: delete as reply to message")
	end
end, 0)

function spam.spamfast(x, n)
	if n > 20 then
		n = 20
	end
	
	while n > 0 do
		send(x, "spam")
		n=n-1
	end
end

function spam.spam(data)
	if data.count > 0 then
		data.count = data.count - 1
		send_msg(data.target, "spam", safeCallback, {spam.spam, data})
	end
end

function spam.history_delete(data, success, result)
	if success ~= 1 or not result or data.count > 100 then
		return false
	end
	
	for k, v in pairs(result) do
		if v.id then
			delete_msg(v.id, void, nil)
			if v.id == data.id then
				return true
			end
		end
	end
	
	data.count = data.count + 10
	get_history(data.peer, 0, 10, safeCallback, {data.f, data})
end