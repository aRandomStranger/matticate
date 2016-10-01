local function changeWarnSettings(chat_id, action)
    local current = tonumber(db:hget('chat:' .. chat_id .. ':warnsettings', 'max')) or 3
    local new_val
    if action == 1 then
        if current > 12 then
            return 'The new value needs to be lower than 12.'
        else
            new_val = db:hincrby('chat:' .. chat_id .. ':warnsettings', 'max', 1)
            return current .. '->' .. new_val
        end
    elseif action == -1 then
        if current < 2 then
            return 'The new value needs to be greater than 1.'
        else
            new_val = db:hincrby('chat:' .. chat_id .. ':warnsettings', 'max', -1)
            return current .. '->' .. new_val
        end
    elseif action == 'status' then
        local status = (db:hget('chat:' .. chat_id .. ':warnsettings', 'type')) or 'kick'
        if status == 'kick' then
            db:hset('chat:' .. chat_id .. ':warnsettings', 'type', 'ban')
            return 'Users will now be *banned* when the reach the maximum amount of warnings.'
        elseif status == 'ban' then
            db:hset('chat:' .. chat_id .. ':warnsettings', 'type', 'kick')
            return 'Users will now be *kicked* when the reach the maximum amount of warnings.'
        end
    end
end
local function changeCharSettings(chat_id, field)
	local chars = {
		arab_kick = 'People who send Arabic messages in this group will now be kicked.',
		arab_ban = 'People who send Arabic messages in this group will now be banned.',
		arab_allow = 'Arabic symbols are now allowed in this group.',
		rtl_kick = 'The use of RTL characters in this group will now result in a kick.',
		rtl_ban = 'The use of RTL characters in this group will now result in a ban.',
		rtl_allow = 'RTL characters are now allowed in this group.'
	}
    local hash = 'chat:' .. chat_id .. ':char'
    local status = db:hget(hash, field)
    local text
    if status == 'allowed' then
        db:hset(hash, field, 'kick')
        text = chars[field:lower() .. 'kick']
    elseif status == 'kick' then
        db:hset(hash, field, 'ban')
        text = chars[field:lower() .. 'ban']
    elseif status == 'ban' then
        db:hset(hash, field, 'allowed')
        text = chars[field:lower() .. 'allow']
    else
        db:hset(hash, field, 'allowed')
        text = chars[field:lower() .. 'allow']
    end
    return text
end
local function usersettings_table(settings, chat_id)
    local return_table = {}
    local icon_off, icon_on = '👤', '👥'
    for field, default in pairs(settings) do
        if field == 'Extra' or field == 'Rules' then
            local status = (db:hget('chat:' .. chat_id .. ':settings', field)) or default
            if status == 'off' then
                return_table[field] = icon_off
            elseif status == 'on' then
                return_table[field] = icon_on
            end
        end
    end 
    return return_table
end
local function adminsettings_table(settings, chat_id)
    local return_table = {}
    local icon_off, icon_on = 'Off', 'On'
    for field, default in pairs(settings) do
        if field ~= 'Extra' and field ~= 'Rules' then
            local status = (db:hget('chat:' .. chat_id .. ':settings', field)) or default
            if status == 'off' then
                return_table[field] = icon_off
            elseif status == 'on' then
                return_table[field] = icon_on
            end
        end
    end 
    return return_table
end
local function charsettings_table(settings, chat_id)
    local return_table = {}
    local icon_allow, icon_not_allow = 'Allow', 'Prevent'
    for field, default in pairs(settings) do
        local status = (db:hget('chat:' .. chat_id .. ':char', field)) or default
        if status == 'kick' or status == 'ban' then
            return_table[field] = icon_not_allow .. ' ' .. status
        elseif status == 'allowed' then
            return_table[field] = icon_allow
        end
    end 
    return return_table
end
local function insert_settings_section(keyboard, settings_section, chat_id)
	local strings = {
		Welcome = 'Welcome Message',
		Extra = 'Extra',
		Flood = 'Anti-Flood',
		Silent = 'Silent Mode',
		Rules = 'Rules',
		Arab = 'Arabic',
		Rtl = 'RTL',
		Antibot = 'Ban Bots'
	}
    for key, icon in pairs(settings_section) do
        local current = {
            {text = strings[key] or key, callback_data = 'menu:alert:settings'},
            {text = icon, callback_data = 'menu:' .. key .. ':' .. chat_id}
        }
        table.insert(keyboard.inline_keyboard, current)
    end 
    return keyboard
end
local function doKeyboard_menu(chat_id)
    local keyboard = {inline_keyboard = {}}
    local settings_section = adminsettings_table(config.chat_settings['settings'], chat_id)
    keyboard = insert_settings_section(keyboard, settings_section, chat_id)
    settings_section = usersettings_table(config.chat_settings['settings'], chat_id)
    keyboard = insert_settings_section(keyboard, settings_section, chat_id)
    settings_section = charsettings_table(config.chat_settings['char'], chat_id)
    keyboard = insert_settings_section(keyboard, settings_section, chat_id)
    local max = (db:hget('chat:' .. chat_id .. ':warnsettings', 'max')) or config.chat_settings['warnsettings']['max']
    local action = (db:hget('chat:' .. chat_id .. ':warnsettings', 'type')) or config.chat_settings['warnsettings']['type']
	if action == 'kick' then
		action = '%d 🔨️ kick'
		action = action:format(tonumber(max))
	else
		action = '%d 🔨️ ban'
		action = action:format(tonumber(max))
	end
    local warn = {
		{text = '-', callback_data = 'menu:DimWarn:' .. chat_id},
		{text = action, callback_data = 'menu:ActionWarn:' .. chat_id},
		{text = '+', callback_data = 'menu:RaiseWarn:' .. chat_id},
    }
    table.insert(keyboard.inline_keyboard, {{text = 'Warnings', callback_data = 'menu:alert:warnings:'}})
    table.insert(keyboard.inline_keyboard, warn)
    table.insert(keyboard.inline_keyboard, {{text = 'Back', callback_data = 'config:back:' .. chat_id}})
    return keyboard
end
local action = function(msg, blocks)
	local menu_first = [[
Manage the settings of the specified group.
]]
    local chat_id = msg.target_id
    local keyboard, text
    if blocks[1] == 'config' then
        keyboard = doKeyboard_menu(chat_id)
        api.editMessageText(msg.chat.id, msg.message_id, menu_first, keyboard, true)
    else
	    if blocks[2] == 'alert' then
	        if blocks[3] == 'settings' then
                text = _("⚠️ Tap on an icon!")
            elseif blocks[3] == 'warnings' then
                text = _("⚠️ Use the keyboard below to change the warning settings!")
            end
            api.answerCallbackQuery(msg.cb_id, text)
            return
        end
        if blocks[2] == 'DimWarn' or blocks[2] == 'RaiseWarn' or blocks[2] == 'ActionWarn' then
            if blocks[2] == 'DimWarn' then
                text = changeWarnSettings(chat_id, -1)
            elseif blocks[2] == 'RaiseWarn' then
                text = changeWarnSettings(chat_id, 1)
            elseif blocks[2] == 'ActionWarn' then
                text = changeWarnSettings(chat_id, 'status')
            end
        elseif blocks[2] == 'Rtl' or blocks[2] == 'Arab' then
            text = changeCharSettings(chat_id, blocks[2])
        else
            text = misc.changeSettingStatus(chat_id, blocks[2])
        end
        keyboard = doKeyboard_menu(chat_id)
        api.editMessageText(msg.chat.id, msg.message_id, menu_first, keyboard, true)
        if text then
        	api.answerCallbackQuery(msg.cb_id, '⚙ ' .. text)
        end
    end
end
return {
	action = action,
	triggers = {
	    '^###cb:(menu):(alert):(settings)',
    	'^###cb:(menu):(alert):(warnings)',
    	'^###cb:(menu):(.*):',
    	'^###cb:(config):menu:(-%d+)$'
	}
}