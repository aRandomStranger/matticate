local function doKeyboard_warn(user_id)
	local keyboard = {}
    keyboard.inline_keyboard = {
    	{
    		{text = 'Reset warnings', callback_data = 'resetwarnings:' .. user_id},
    		{text = 'Remove warning', callback_data = 'removewarning:' .. user_id}
    	}
    }
    return keyboard
end
local function action(msg, blocks)
    if msg.chat.type == 'private' then
    	return
    end
    if not roles.is_admin(msg) then
    	if msg.cb then
    		api.answerCallbackQuery(msg.cb_id, 'You\'re not an admin.')
    	end
    	return
    end
    if blocks[1] == 'warnmax' then
    	local new, default, text, key
    	local hash = 'chat:' .. msg.chat.id .. ':warnsettings'
    	if blocks[2] == 'media' then
    		new = blocks[3]
    		default = 2
    		key = 'mediamax'
			text = 'The maximum number of warnings a user can receive for sending prohibited media has been changed.\n'
    	else
    		key = 'max'
    		new = blocks[2]
    		default = 3
			text = 'The maximum number of warnings a user can receive has been changed.\n'
    	end
		local old = (db:hget(hash, key)) or default
		db:hset(hash, key, new)
		text = text .. 'A user can now receive %s warnings before being kicked/banned.'
		text = text:format(tonumber(new))
        api.sendReply(msg, text, true)
        return
    end
    if blocks[1] == 'resetwarnings' and msg.cb then
    	local user_id = blocks[2]
    	print(msg.chat.id, user_id)
    	db:hdel('chat:' .. msg.chat.id .. ':warnings', user_id)
		db:hdel('chat:' .. msg.chat.id .. ':mediawarn', user_id)
		local text = 'Warning count reset by %s.'
		text = text:format(misc.getname_final(msg.from))
		api.editMessageText(msg.chat.id, msg.message_id, text, false, true)
		return
	end
	if blocks[1] == 'removewarning' and msg.cb then
    	local user_id = blocks[2]
		local num = db:hincrby('chat:' .. msg.chat.id .. ':warnings', user_id, -1)
		local text, nmax, diff
		if tonumber(num) < 0 then
			text = 'The number of warnings received by this user is already zero'
			db:hincrby('chat:' .. msg.chat.id .. ':warnings', user_id, 1)
		else
			nmax = (db:hget('chat:' .. msg.chat.id .. ':warnsettings', 'max')) or 3
			diff = nmax - num
			text = 'Warning removed! (%d/%d)'
			text = text:format(tonumber(num), tonumber(nmax))
		end
		text = text .. '\n(Admin: %s)'
		text = text:format(misc.getname_final(msg.from))
		api.editMessageText(msg.chat.id, msg.message_id, text, false, true)
		return
	end
    if not msg.reply or roles.is_admin_cached(msg.reply) or msg.reply.from.id == bot.id then
	    return
	end
    if blocks[1] == 'warn' then
	    local name = misc.getname_final(msg.reply.from)
		local hash = 'chat:' .. msg.chat.id .. ':warnings'
		local num = db:hincrby(hash, msg.reply.from.id, 1)
		local nmax = (db:hget('chat:' .. msg.chat.id .. ':warnsettings', 'max')) or 3
		local text, res, motivation
		num, nmax = tonumber(num), tonumber(nmax)
		if num >= nmax then
			local type = (db:hget('chat:' .. msg.chat.id .. ':warnsettings', 'type')) or 'kick'
			if type == 'ban' then
				text = '%s has been banned for reaching the maximum number of warnings allowed'
				text = text:format(name)
				res, motivation = api.banUser(msg.chat.id, msg.reply.from.id)
	    	else
				text = '%s has been kicked for reaching the maximum number of warnings allowed'
				text = text:format(name)
		    	res, motivation = api.kickUser(msg.chat.id, msg.reply.from.id)
		    end
		    if not res then
		    	if not motivation then
		    		motivation = 'I can\'t kick this user.\nEither I\'m not an admin, or the targeted user is.'
		    	end
		    	text = motivation
		    else
		    	misc.saveBan(msg.reply.from.id, 'warn')
		    	db:hdel('chat:' .. msg.chat.id .. ':warnings', msg.reply.from.id)
		    	db:hdel('chat:' .. msg.chat.id .. ':mediawarn', msg.reply.from.id)
		    end
		    api.sendReply(msg, text, true)
		else
			local diff = nmax - num
			text = '%s has been warned (%d/%d).'
			text = text:format(name, num, nmax)
			local keyboard = doKeyboard_warn(msg.reply.from.id)
			api.sendKeyboard(msg.chat.id, text, keyboard, true)
		end
    end
end
return {
	action = action,
	triggers = {
		config.cmd .. '(warnmax) (%d%d?)$',
		config.cmd .. '(warnmax) (media) (%d%d?)$',
		config.cmd .. '(warn)$',
		config.cmd .. '(warn) (.*)$',
		'^###cb:(resetwarnings):(%d+)$',
		'^###cb:(removewarning):(%d+)$'
	}
}