local function do_keyboard_credits()
	local keyboard = {}
    keyboard.inline_keyboard = {
    	{
    		{text = 'Official Channel', url = 'https://telegram.me/' .. config.channel:gsub('@', '')},
    		{text = 'GitHub', url = 'https://github.com/matthewhesketh/matticate'}
		},
		{
			{text = 'Groups', callback_data = 'private:groups'}
		}
	}
	return keyboard
end
local action = function(msg, blocks)
    if msg.chat.type ~= 'private' then
    	return
    end
	if blocks[1] == 'ping' then
		local res = api.sendMessage(msg.from.id, 'Pong!', true)
	end
	if blocks[1] == 'echo' then
		local res, code = api.sendMessage(msg.chat.id, blocks[2], true)
		if not res then
			if code == 118 then
				api.sendMessage(msg.chat.id, 'I can\'t send this message because it\'s too long.')
			end
		end
	end
	if blocks[1] == 'about' then
		local keyboard = do_keyboard_credits()
		local text = 'This bot is based on [Group Butler](https://github.com/RememberTheAir/GroupButler).\n\nHere are some useful links:'
		if msg.cb then
			api.editMessageText(msg.chat.id, msg.message_id, text, keyboard, true)
		else
			api.sendKeyboard(msg.chat.id, text, keyboard, true)
		end
	end
	if blocks[1] == 'groups' then
		if config.groups and next(config.groups) then
			keyboard = {inline_keyboard = {}}
			for group, link in pairs(config.groups) do
				if link then
					local line = {{text = group, url = link}}
					table.insert(keyboard.inline_keyboard, line)
				end
			end
			if next(keyboard.inline_keyboard) then
				if msg.cb then
					api.editMessageText(msg.chat.id, msg.message_id, 'Official Groups:', keyboard, true)
				else
					api.sendKeyboard(msg.chat.id, 'Official Groups:', keyboard, true)
				end
			end
		end
	end
end

return {
	action = action,
	triggers = {
		config.cmd .. '(ping)$',
		config.cmd .. '(echo) (.*)$',
		config.cmd .. '(about)$',
		config.cmd .. '(groups)$',
		'^/start (groups)$',
		'^###cb:fromhelp:(about)$',
		'^###cb:private:(groups)$',
		'^###cb:(sendpo):(.*)$'
	}
}