local function do_keyboard_flood(chat_id)
    local status = db:hget('chat:' .. chat_id .. ':settings', 'Flood') or config.chat_settings['settings']['Flood']
    if status == 'on' then
        status = 'On'
    elseif status == 'off' then
        status = 'Off'
    end
    local hash = 'chat:'..chat_id..':flood'
    local action = (db:hget(hash, 'ActionFlood')) or config.chat_settings['flood']['ActionFlood']
    if action == 'kick' then
        action = 'Kick'
    else
        action = 'Ban'
    end
    local num = (db:hget(hash, 'MaxFlood')) or config.chat_settings['flood']['MaxFlood']
    local keyboard = {
        inline_keyboard = {
            {
                {text = status, callback_data = 'flood:status:' .. chat_id},
                {text = action, callback_data = 'flood:action:' .. chat_id},
            },
            {
                {text = '-', callback_data = 'flood:dim:' .. chat_id},
                {text = num, callback_data = 'flood:alert:num'},
                {text = '+', callback_data = 'flood:raise:' .. chat_id},
            }
        }
    }
    local exceptions = {
        text = 'Texts',
        sticker = 'Stickers',
        image = 'Images',
        gif = 'GIFs',
        video = 'Videos'
    }
    local hash = 'chat:' .. chat_id .. ':floodexceptions'
    for media, translation in pairs(exceptions) do
        local exc_status = (db:hget(hash, media)) or config.chat_settings['floodexceptions'][media]
        if exc_status == 'yes' then
            exc_status = 'Yes'
        else
            exc_status = 'No'
        end
        local line = {
            {text = translation, callback_data = 'flood:alert:voice'},
            {text = exc_status, callback_data = 'flood:exc:' .. media .. ':' .. chat_id}
        }
        table.insert(keyboard.inline_keyboard, line)
    end
    table.insert(keyboard.inline_keyboard, {{text = 'Back', callback_data = 'config:back:' .. chat_id}})
    return keyboard
end
local function action(msg, blocks)
	local header = [[
Here you can configure the anti-flood plugin for the specified group.
]]
    if not msg.cb and msg.chat.type == 'private' then
    	return
    end
    local chat_id = msg.target_id or msg.chat.id
    local text, keyboard
    if blocks[1] == 'antiflood' then
        if not roles.is_admin_cached(msg) then
        	return
        end
        if blocks[2]:match('%d%d?') then
            if tonumber(blocks[2]) < 4 or tonumber(blocks[2]) > 25 then
				local text = '%s is not a valid value.\nThe value should be greater than 3 but lower than 26.'
				text = text:format(blocks[1])
				api.sendReply(msg, text, true)
			else
	    	    local new = tonumber(blocks[2])
	    	    local old = tonumber(db:hget('chat:' .. msg.chat.id .. ':flood', 'MaxFlood')) or config.chat_settings['flood']['MaxFlood']
	    	    if new == old then
	    	    	local text = 'The maximum number of messages that can be sent in 5 seconds is already %d.'
	    	    	text = text:format(new)
	            	api.sendReply(msg, text, true)
	    	    else
	            	db:hset('chat:' .. msg.chat.id .. ':flood', 'MaxFlood', new)
					local text = 'The maximum number of messages that can be sent in 5 seconds has been changed from %d to %d.'
					text = text:format(old, new)
	            	api.sendReply(msg, text, true)
	    	    end
            end
            return
        end
    else
        if not msg.cb then
        	return
        end
        if blocks[1] == 'config' then
            keyboard = do_keyboard_flood(chat_id)
            api.editMessageText(msg.chat.id, msg.message_id, header, keyboard, true)
            return
        end
        if blocks[1] == 'alert' then
            if blocks[2] == 'num' then
                text = '⚖ Tap on the + or the - to adjust the current sensitivity.'
            elseif blocks[2] == 'voice' then
                text = '⚠️ Tap on an icon!'
            end
            api.answerCallbackQuery(msg.cb_id, text)
            return
        end
        if blocks[1] == 'exc' then
            local media = blocks[2]
            local hash = 'chat:' .. chat_id .. ':floodexceptions'
            local status = (db:hget(hash, media)) or 'no'
            if status == 'no' then
                db:hset(hash, media, 'yes')
                text = '[%s] will now be ignored by the anti-flood plugin.'
                text = text:format(media)
            else
                db:hset(hash, media, 'no')
                text = '[%s] will no longer be ignored by the anti-flood plugin.'
                text = text:format(media)
            end
        end
        local action
        if blocks[1] == 'action' or blocks[1] == 'dim' or blocks[1] == 'raise' then
            if blocks[1] == 'action' then
                action = (db:hget('chat:' .. chat_id .. ':flood', 'ActionFlood')) or 'kick'
            elseif blocks[1] == 'dim' then
                action = -1
            elseif blocks[1] == 'raise' then
                action = 1
            end
            text = misc.changeFloodSettings(chat_id, action):escape_hard()
        end
        if blocks[1] == 'status' then
            local status = db:hget('chat:' .. chat_id .. ':settings', 'Flood') or config.chat_settings['settings']['Flood']
            text = misc.changeSettingStatus(chat_id, 'Flood'):escape_hard()
        end
        keyboard = do_keyboard_flood(chat_id)
        api.editMessageText(msg.chat.id, msg.message_id, header, keyboard, true)
        api.answerCallbackQuery(msg.cb_id, text)
    end
end
return {
    action = action,
    triggers = {
        config.cmd .. '(antiflood) (%d%d?)$',     
        '^###cb:flood:(alert):(%w+)$',
        '^###cb:flood:(status):(-%d+)$',
        '^###cb:flood:(action):(-%d+)$',
        '^###cb:flood:(dim):(-%d+)$',
        '^###cb:flood:(raise):(-%d+)$',
        '^###cb:flood:(exc):(%a+):(-%d+)$',
        '^###cb:(config):antiflood:'
    }
}
