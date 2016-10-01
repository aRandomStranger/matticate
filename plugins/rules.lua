local function send_in_group(chat_id)
	local res = db:hget('chat:' .. chat_id .. ':settings', 'Rules')
	if res == 'on' then
		return true
	else
		return false
	end
end
local action = function(msg, blocks)
    if msg.chat.type == 'private' then
    	if blocks[1] == 'start' then
    		msg.chat.id = tonumber(blocks[2])
    	else
    		return
    	end
    end
    local hash = 'chat:' .. msg.chat.id .. ':info'
    if blocks[1] == 'rules' or blocks[1] == 'start' then
        local out = misc.getRules(msg.chat.id)
    	if msg.chat.type == 'private' or (not roles.is_admin_cached(msg) and not send_in_group(msg.chat.id)) then
    		api.sendMessage(msg.from.id, out, true)
    	else
        	api.sendReply(msg, out, true)
        end
    end
	if not roles.is_admin_cached(msg) then
		return
	end
	if blocks[1] == 'setrules' then
		local input = blocks[2]
		if not input then
			api.sendReply(msg, 'You need to specify some rules.', true)
			return
		end
		if input == '-del' then
			db:hdel(hash, 'rules')
			api.sendReply(msg, 'The rules for this group have been deleted.')
			return
		end
		local res, code = api.sendReply(msg, input, true)
		if not res then
			if code == 118 then
				api.sendMessage(msg.chat.id, 'I can\'t send that message because it\'s too long')
			else
				api.sendMessage(msg.chat.id, 'This text breaks the markdown', true)
			end
		else
			db:hset(hash, 'rules', input)
			local id = res.result.message_id
			api.editMessageText(msg.chat.id, id, 'Successfully saved the new rules!', false, true)
		end
	end

end
return {
	action = action,
	triggers = {
		config.cmd .. '(setrules)$',
		config.cmd .. '(setrules) (.*)',
		config.cmd .. '(rules)$',
		'^/(start) (-%d+):rules$'
	}
}