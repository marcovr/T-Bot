------ Event handling ------
function on_startup_ready() -- gets triggered after startup as soon as messaging is ready
	_print("ready for messaging!")
	hook.call("on_startup_ready")
end

function on_cron_interval() -- can be triggered by cronjob
	--_print("cron interval triggered!")
	hook.call("on_cron_interval")
end

function on_binlog_replay_end()
	hook.call("tg_BinLogReplayEnd")
end

function on_get_difference_end()
	hook.call("tg_GetDifferenceEnd")
end

function on_our_id(our_id)
	hook.call("tg_OurId", our_id)
end

function on_msg_receive(msg)
	if started then
		lastmsg = msg
		if not msg.out then
			if msg.to.peer_type == "user" then
				msg.to.print_name = msg.from.print_name
			end
			hook.call("tg_MsgReceive", msg)
		end
	end
end

function on_user_update(user, what_changed)
	hook.call("tg_UserUpdate", user, what_changed)
end

function on_chat_update(user, what_changed)
	hook.call("tg_ChatUpdate", user, what_changed)
end

function on_secret_chat_update(user, what_changed)
	hook.call("tg_SecretChatUpdate", user, what_changed)
end

function void(arg, success, result)
end