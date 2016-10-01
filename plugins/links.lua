local action = function(msg, blocks)
    if msg.chat.type == 'private' then
    	return
    end
	if not roles.is_admin_cached(msg) then
		return
	end
	local hash = 'chat:' .. msg.chat.id .. ':links'
	local text
	if blocks[1] == 'link' then
		local key = 'link'
		local link = db:hget(hash, key)
		if not link then
			text = _('No link has been set for this group.')
		else
			local title = msg.chat.title:escape_hard()
			text = string.format('[%s](%s)', title, link)
		end
		api.sendReply(msg, text, true)
	end
	
	if blocks[1] == 'setlink' then
		local link
		if msg.chat.username then
			link = 'https://telegram.me/' .. msg.chat.username
		else
			if not blocks[2] then
				local text = _('This is not a public supergroup, so you need to send `/setlink <link>`.')
				api.sendReply(msg, text, true)
				return
			end
			if string.len(blocks[2]) ~= 22 and blocks[2] ~= '-' then
				api.sendReply(msg, _('That link is invalid.'), true)
				return
			end
			link = 'https://telegram.me/joinchat/' .. blocks[2]
		end
		local key = 'link'
		if blocks[2] and blocks[2] == '-' then
			db:hdel(hash, key)
			text = _('This group\'s link has been removed')
		else
			local succ = db:hset(hash, key, link)
			local title = msg.chat.title:escape_hard()
			local substitution = '[' .. title .. '](' .. link .. ')'
			if succ == false then
				text = _('The link has been updated.\nHere\'s the new link: %s'):format(substitution)
			else
				text = _('The link has been set.\nHere\'s the link: %s'):format(substitution)
			end
		end
		api.sendReply(msg, text, true)
	end
end
return {
	action = action,
	triggers = {
		config.cmd..'(link)$',
		config.cmd..'(setlink)$',
		config.cmd..'(setlink) https://telegram%.me/joinchat/(.*)',
		config.cmd..'(setlink) (-)'
	}
}