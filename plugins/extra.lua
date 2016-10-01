local function is_locked(chat_id)
  	local hash = 'chat:' .. chat_id .. ':settings'
  	local current = db:hget(hash, 'Extra Commands')
  	if current == 'off' then
  		return true
  	else
  		return false
  	end
end
local action = function(msg, blocks)
	if msg.chat.type == 'private' then
		return
	end
	if blocks[1] == 'extra' then
		if not roles.is_admin_cached(msg) then
			return
		end
		if not blocks[2] then
			return
		end
		if not blocks[3] and not msg.reply then
			return
		end
	    if msg.reply and not blocks[3] then
	    	local file_id, media_with_special_method = misc.get_media_id(msg.reply)
	    	if not file_id then
	    		return
	    	else
	    		local to_save
	    		if media_with_special_method then
	    			to_save = '###file_id!' .. media_with_special_method .. '###:' .. file_id
	    		else
	    			to_save = '###file_id###:' .. file_id
	    		end
	    		db:hset('chat:' .. msg.chat.id .. ':extra', blocks[2], to_save)
	    		local text = 'This media has been saved as a response to %s.'
	    		text = text:format(blocks[2])
	    		api.sendReply(msg, text)
	    	end
		else
	    	local hash = 'chat:' .. msg.chat.id .. ':extra'
	    	
	    	local res, code = api.sendReply(msg, blocks[3]:replaceholders(msg), true)
	    	if not res then
	    		if code == 118 then
					api.sendMessage(msg.chat.id, 'I can\'t send this message because it\'s too long.')
				else
					local text = 'This text breaks the markdown.'
					api.sendMessage(msg.chat.id, text, true)
				end
    		else
	    		db:hset(hash, blocks[2], blocks[3])
	    		local msg_id = res.result.message_id
	    		local text = 'The command \'%s\' has been saved!'
	    		text = text:format(blocks[2])
				api.editMessageText(msg.chat.id, msg_id, text, false)
    		end
    	end
	elseif blocks[1] == 'extra list' then
	    if not roles.is_admin_cached(msg) then
	    	return
	    end
	    local hash = 'chat:' .. msg.chat.id .. ':extra'
	    local commands = db:hkeys(hash)
	    local text = ''
	    if commands[1] == nil then
	        api.sendReply(msg, 'No commands have been set.')
	    else
	        for k, v in pairs(commands) do
	            text = text .. v .. '\n'
	        end
	        local out = 'List of custom commands:\n' .. text
	        api.sendReply(msg, out, true)
	    end
    elseif blocks[1] == 'extra del' then
        if not roles.is_admin_cached(msg) then
    		return
    	end
	    local hash = 'chat:' .. msg.chat.id .. ':extra'
	    local success = db:hdel(hash, blocks[2])
	    if success == 1 then
	    	local out = 'The command \'%s\' has been deleted.'
	    	out = out:format(blocks[2])
	        api.sendReply(msg, out)
	    else
	        local out = 'The command \'%s\' does not exist'
	        out = out:format(blocks[2])
	        api.sendReply(msg, out)
	    end
    else
    	local hash = 'chat:' .. msg.chat.id .. ':extra'
    	local text = db:hget(hash, blocks[1])
        if not text then
        	return true
        end
        local file_id = text:match('^###.+###:(.*)')
        local special_method = text:match('^###file_id!(.*)###')
        if is_locked(msg.chat.id) and not roles.is_admin_cached(msg) then
        	if not file_id then
            	api.sendMessage(msg.from.id, text, true)
            else
            	if special_method then
            		api.sendMediaId(msg.from.id, file_id, special_method)
            	else
            		api.sendDocumentId(msg.from.id, file_id)
            	end
            end
        else
        	local msg_to_reply
        	if msg.reply then
        		msg_to_reply = msg.reply.message_id
        	else
        		msg_to_reply = msg.message_id
        	end
        	if file_id then
        		if special_method then
        			api.sendMediaId(msg.chat.id, file_id, special_method, msg_to_reply)
        		else
        			api.sendDocumentId(msg.chat.id, file_id, msg_to_reply)
        		end
        	else
        		api.sendMessage(msg.chat.id, text:replaceholders(msg.reply or msg), true, msg_to_reply)
        	end
        end
    end
end
return {
	action = action,
	triggers = {
		config.cmd .. '(extra)$',
		config.cmd .. '(extra) (#[%w_]*)%s(.*)$',
		config.cmd .. '(extra) (#[%w_]*)',
		config.cmd .. '(extra del) (#[%w_]*)$',
		config.cmd .. '(extra list)$',
		'^(#[%w_]*)$'
	}
}