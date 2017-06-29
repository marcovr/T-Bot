--[[ Docs:
The messaging library provides several functions to easily send messages and also contains the main message handler.

send(peer, [markup,] ...)
	Sends a message to peer (optionally with markup).

answer(msg, [markup,] ...)
	Same as send, but triggers a reply to msg if in a group chat.

log([markup,] ...)
	Sends the message to the main group using send.
]]

-- A single wrapper function for four functions: reply/send, markup/none
local function send_msg_ext(msg, markup, reply, text)
	if reply then
		if markup then
			reply_markupmsg(msg.id, text, void, nil)
		else
			reply_msg(msg.id, text, void, nil)
		end
	else
		if markup then
			send_markupmsg(msg, text, void, nil)
		else
			send_msg(msg, text, void, nil)
		end
	end
end

-- A wrapper function to split long messages
local function send_text(peer, markup, reply, text)
	-- split message if too long
	local n = 1
	while text:len() > 4000 do
		local part = text:sub(1, 4000)
		local i = part:match'^.*()\n'
		
		if i and i > 3000 then
			part = part:sub(1, i)
			text = text:sub(i + 1)
		else
			text = text:sub(4001)
		end
		
		part = part.."\n[Part "..n.."]"
		n = n + 1
		
		send_msg_ext(peer, markup, reply, part)
	end
	
	if n > 1 then
		text = text.."\n[End]"
	end
	
	send_msg_ext(peer, markup, reply, text)
end


---- Actual functions ----

function send(peer, markup, ...)
	if type(peer) == "table" then
		peer = peer.to.print_name
	end
	
	if type(markup) == "boolean" and select("#", ...) > 0 then
		local text = "["..botName.."]"..stringify(...)
		send_text(peer, markup, false, text)
	else
		local text = "["..botName.."]"..stringify(markup, ...)
		send_text(peer, false, false, text)
	end
end

function answer(msg, markup, ...)
	if type(msg) == "table" then
		if msg.to.peer_type ~= "user" then
			if type(markup) == "boolean" and select("#", ...) > 0 then
				local text = "["..botName.."]"..stringify(...)
				send_text(msg, markup, true, text)
			else
				local text = "["..botName.."]"..stringify(markup, ...)
				send_text(msg, false, true, text)
			end
		else
			send(msg, markup, ...)
		end
	else
		send(msg, markup, ...)
	end
end

function log(...)
	send(mainGroup, ...)
end

-- Message handler
hook.add("tg_MsgReceive", "processMessage", function(msg)
	--[[if not msg.text and not msg.media or msg.service then
		print(table.show(msg))
		return
	end]]--
	
	if msg.text then	
		if string.sub(msg.text, 1, 1) == "!" or string.sub(msg.text, 1, 1) == "/" then
			commands.handle(msg)
		else
			if msg.to.peer_type == "user" then
				mark_read(msg.to.print_name, void, nil)
				if msg.from.print_name == "Telegram" then
					log(msg.text)
				end
			end
		end
	end
end)