local function getFloodSettings_text(chat_id)
    local status = db:hget('chat:' .. chat_id .. ':settings', 'Flood') or 'yes'
    if status == 'no' then
        status = 'On'
    elseif status == 'yes' then
        status = 'Off'
    end
    local hash = 'chat:' .. chat_id .. ':flood'
    local action = (db:hget(hash, 'ActionFlood')) or 'kick'
    if action == 'kick' then
        action = 'Kick'
    else
        action = 'Ban'
    end
    local num = (db:hget(hash, 'MaxFlood')) or 5
    local exceptions = {
        text = 'Texts',
        sticker = 'Stickers',
        image = 'Images',
        gif = 'GIFs',
        video = 'Videos'
    }
    hash = 'chat:' .. chat_id .. ':floodexceptions'
    local list_exc = ''
    for media, translation in pairs(exceptions) do
        local exc_status = (db:hget(hash, media)) or 'no'
        if exc_status == 'yes' then
            exc_status = 'Yes'
        else
            exc_status = 'No'
        end
        list_exc = list_exc .. '• `' .. translation .. '`: ' .. exc_status .. '\n'
    end
	local format_status = '*Status*: `%s`\n'
    format_status = format_status:format(status)
	local format_action = 'Action to perform when an user floods chat: `%s`\n'
	format_action = format_action:format(action)
	local format_num = 'Number of messages allowed every 5 seconds: `%d`\n'
	format_num = format_num:format(num)
	local format_list_exc = 'Media to ignore:\n%s'
	format_list_exc = format_list_exc:format(list_exc)
	local text = format_status .. format_action .. format_num .. format_list_exc
	return text
end
local function doKeyboard_dashboard(chat_id)
    local keyboard = {}
    keyboard.inline_keyboard = {
	    {
            {text = 'Settings', callback_data = 'dashboard:settings:' .. chat_id},
            {text = 'Admins', callback_data = 'dashboard:adminlist:' .. chat_id}
		},
	    {
		    {text = 'Rules', callback_data = 'dashboard:rules:' .. chat_id},
		    {text = 'Extra Commands', callback_data = 'dashboard:extra:' .. chat_id}
        },
	    {
	   	    {text = 'Flood Settings', callback_data = 'dashboard:flood:' .. chat_id},
	   	    {text = 'Media Settings', callback_data = 'dashboard:media:' .. chat_id}
	    },
    }
    return keyboard
end
local action = function(msg, blocks)
    local chat_id = msg.target_id or msg.chat.id
    local keyboard = {}
    if not(msg.chat.type == 'private') and not msg.cb then
        keyboard = doKeyboard_dashboard(chat_id)
        local res = api.sendKeyboard(msg.from.id, 'Navigate this message to see information about the given group.', keyboard, true)
        if not misc.is_silentmode_on(msg.chat.id) then
            if res then
                api.sendMessage(msg.chat.id, 'I\'ve sent you the group dashboard via private message.', true)
            else
                misc.sendStartMe(msg, msg.ln)
            end
        end
	    return
    end
    if msg.cb then
        local request = blocks[2]
        local text
        keyboard = doKeyboard_dashboard(chat_id)
        if request == 'settings' then
            text = misc.getSettings(chat_id)
        end
        if request == 'rules' then
            text = misc.getRules(chat_id)
        end
        if request == 'adminlist' then
            local creator, admins = misc.getAdminlist(chat_id)
            if not creator then
                text = 'I need to be an admin in this group to see a list of all admins.'
            else
                text = '*Creator*:\n%s\n\n*Admins*:\n%s'
                text = text:format(creator, admins)
            end
        end
        if request == 'extra' then
            text = misc.getExtraList(chat_id)
        end
        if request == 'flood' then
            text = getFloodSettings_text(chat_id)
        end
        if request == 'media' then
            text = '*Current media settings*:\n\n'
            for media, default_status in pairs(config.chat_settings['media']) do
                local status = (db:hget('chat:' .. chat_id .. ':media', media)) or default_status
                if status == 'ok' then
                    status = 'Allowed'
                else
                    status = 'Forbidden'
                end
                text = text .. '`' .. media .. '` ≡ ' .. status .. '\n'
            end
        end
        api.editMessageText(msg.chat.id, msg.message_id, text, keyboard, true)
        api.answerCallbackQuery(msg.cb_id, 'ℹ️ Group ► ' .. request)
        return
    end
end
return {
	action = action,
	triggers = {
		config.cmd .. '(dashboard)$',
		'^###cb:(dashboard):(%a+):(-%d+)'
	}
}