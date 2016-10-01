local function doKeyboard_media(chat_id)
	if not ln then
		ln = 'en'
	end
    local keyboard = {}
    keyboard.inline_keyboard = {}
    for media, default_status in pairs(config.chat_settings['media']) do
    	local status = (db:hget('chat:' .. chat_id .. ':media', media)) or default_status
        if status == 'ok' then
            status = '✅'
        else
            status = '❌'
        end

		local media_texts = {
			image = _("Images"),
			gif = _("GIFs"),
			video = _("Videos"),
			file = _("Documents"),
			TGlink = _("telegram.me links"),
			voice = _("Vocal messages"),
			link = _("Links"),
			audio = _("Music"),
			sticker = _("Stickers"),
			contact = _("Contacts"),
		}
        local media_text = media_texts[media] or media
        local line = {
            {text = media_text, callback_data = 'mediaalert'},
            {text = status, callback_data = 'media:' .. media .. ':' .. chat_id}
        }
        table.insert(keyboard.inline_keyboard, line)
    end
    local max = (db:hget('chat:' .. chat_id .. ':warnsettings', 'mediamax')) or config.chat_settings['warnsettings']['mediamax']
    local action = (db:hget('chat:' .. chat_id .. ':warnsettings', 'mediatype')) or config.chat_settings['warnsettings']['mediatype']
	local caption
	if action == 'kick' then
		caption = _("Warnings (media) 📍 %d | kick"):format(tonumber(max))
	else
		caption = _("Warnings (media) 📍 %d | ban"):format(tonumber(max))
	end
    table.insert(keyboard.inline_keyboard, {{text = caption, callback_data = 'mediatype:' .. chat_id}})
    local warn = {
        {text = '-', callback_data = 'mediawarn:dim:'..chat_id},
        {text = '+', callback_data = 'mediawarn:raise:'..chat_id},
    }
    table.insert(keyboard.inline_keyboard, warn)
    table.insert(keyboard.inline_keyboard, {{text = 'Back', callback_data = 'config:back:' .. chat_id}})
    return keyboard
end
local action = function(msg, blocks)
	local media_first = _([[
Here you can change how many warnings should be given before I kick/ban someone for sending a forbidden type of media.
]])

	local chat_id = msg.target_id
	
	if  blocks[1] == 'config' then
		local keyboard = doKeyboard_media(chat_id)
	    api.editMessageText(msg.chat.id, msg.message_id, media_first, keyboard, true)
	else
		if blocks[1] == 'mediaalert' then
			api.answerCallbackQuery(msg.cb_id, _("⚠️ Tap on the right column"))
			return
		end
		local cb_text
		if blocks[1] == 'mediawarn' then
			local current = tonumber(db:hget('chat:' .. chat_id .. ':warnsettings', 'mediamax')) or 2
			if blocks[2] == 'dim' then
				if current < 2 then
					cb_text = _('The new value needs to be greater than 1.')
				else
					local new = db:hincrby('chat:' .. chat_id .. ':warnsettings', 'mediamax', -1)
					cb_text = string.format('⚙ %d → %d', current, new)
				end
			elseif blocks[2] == 'raise' then
				if current > 11 then
					cb_text = _('The new value needs to be lower than 12.')
				else
					local new = db:hincrby('chat:' .. chat_id .. ':warnsettings', 'mediamax', 1)
					cb_text = string.format('⚙ %d → %d', current, new)
				end
			end
		end
		if blocks[1] == 'mediatype' then
			local hash = 'chat:' .. chat_id .. ':warnsettings'
			local current = (db:hget(hash, 'mediatype')) or config.chat_settings['warnsettings']['mediatype']
			if current == 'ban' then
				db:hset(hash, 'mediatype', 'kick')
				cb_text = _('Users will now be kicked.')
			else
				db:hset(hash, 'mediatype', 'ban')
				cb_text = _('Users will now be banned.')
			end
		end
		if blocks[1] == 'media' then
			local media = blocks[2]
	    	cb_text = '⚡️ ' .. misc.changeMediaStatus(chat_id, media, 'next')
        end
        keyboard = doKeyboard_media(chat_id)
		api.editMessageText(msg.chat.id, msg.message_id, media_first, keyboard, true)
        api.answerCallbackQuery(msg.cb_id, cb_text)
    end
end

return {
	action = action,
	triggers = {
		'^###cb:(media):(%a+):(-%d+)',
		'^###cb:(mediatype):(-%d+)',
		'^###cb:(mediawarn):(%a+):(-%d+)',
		'^###cb:(mediaalert)',
		'^###cb:(config):media:(-%d+)$'
	}
}