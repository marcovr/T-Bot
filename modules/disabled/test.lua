addCommand("test", function(msg, args)
	hook.Add("tg_MsgReceive", "test", function(msg)
		if(msg.text == nil) then	
			if(load_document(msg.id, no_sense, false) == true) then
				send_text(msg.to.print_name, table.show(msg))
				send_text(msg.to.print_name, "["..botName.."] File found, downloading...")
			else
				send_text(msg.to.print_name, "["..botName.."] ERROR: Could not save file.")
			end
			hook.Remove("tg_MsgReceive", "test")
		end
	end)
end)