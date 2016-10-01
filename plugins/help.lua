local function get_helped_string(key)
	if key == 'private' then
		return [[
Hello *%s*!
I'm matticate, a counter-part administration bot to mattata and a de-crapified version of Group Butler.

*I can do a lot of cool things* - here are just a few of them:
• I can *kick* or *ban* users
• You can use me to set the group rules
• I have a customisable *anti-flood* plugin
• I can *welcome new users* with a customisable message
• I can *warn* users, and perform a configurable action on them when they reach the maximum number of warnings
• I can also warn, kick or ban users when they post specific types of media

I work at my best when I'm an administrator in your group (otherwise I won't be able to kick or ban users)
]]
	elseif key == 'user_commands' then
		return [[
*User Commands*

/dashboard - Shows information about the specified group, in a private message.
/rules - Shows the group rules, in a private message.
/adminlist - Shows the admins of the specified group, in a private message.
/kickme - Kicks you from the group you execute the command in.
/about - Show some useful information.
/groups - Show the list of the discussion groups.
/help - Shows this message.
]]
	elseif key == 'edit_group_information' then
		return [[
*Information about the specified group*

/setrules <group rules> - Set (or update) rules for the group.
/setlink <link> - Set the link for the group. If the group is a public supergroup, you can just send /setlink.
/link - View the group's link.
/msglink - Get the link to a specified message. This only works in public supergroups.
]]
	elseif key == 'edit_banhammer' then
		return [[
*Banhammer Powers*

/kick <username/id> = Kicks the specified user from the group.
/ban <username/id> = Ban the specified user from the group.
/tempban <hours> = Ban the specified user for the given number of hours. This can only be executed via reply.
/unban <username/id> - Unban the specified user from the group.
/user <username/id> - Shows how many times the user has been banned in all matticate-administrated groups, and the warnings he/she has received.
/status <username/id> - Show the current status of the specified user.
]]
	elseif key == 'edit_flood_manager' then
		return [[
*Flood Settings*
]]
	elseif key == 'edit_media_settings' then
		return [[
*Media Settings*
]]
	elseif key == 'edit_welcome_settings' then
		return [[
*Welcome Settings*
]]
	elseif key == 'edit_extra_commands' then
		return [[
*Extra Commands*

/extra <#trigger> <response> - Creates a custom #command in your group.
/extra list - Returns a list of all of your custom commands.
/extra del <#trigger> - Deletes the specified trigger.

For example, executing the command '/extra #ping Pong!' will configure me to reply with 'Pong!' every time somebody sends #ping in your group. This works with media too, by replying to the media with '/extra #trigger'.
]]
	elseif key == 'edit_warnings' then
		return [[
*Warnings*

/warn <username/id> - Warn the specified user. Once the maximum number of warnings allowed is reached, he/she will be kicked/banned - depending on how you\'ve configured me for your group.

Use /user to view information about the specified user, including the amount of warns they have received.
]]
	elseif key == 'edit_general_settings' then
		return [[
*Group Settings*

/config - Manage the group\'s settings via private message.

*The inline keyboard has three sub-menus:*
Menu - Manage the important settings for your groups.
Anti-flood - Toggle the anti-flood plugin, and configure it to meet your group's needs.
Media - Choose which media to prohibit in your group, and set the number of times that an user can be warned before being kicked/banned.
]]
	else
		error('Bad Key.')
	end
end
local function make_keyboard(admin, admin_current_position)
	local keyboard = {}
	keyboard.inline_keyboard = {}
	if admin then
	    local list = {
	        ['Banhammer'] = 'banhammer',
	        ['Group Information'] = 'group_information',
	        ['Flood Manager'] = 'flood_manager',
	        ['Media Settings'] = 'media_settings',
	        ['Welcome Settings'] = 'welcome_settings',
	        ['General Settings'] = 'general_settings',
	        ['Extra Commands'] = 'extra_commands',
	        ['Warnings'] = 'warnings'
        }
        local line = {}
        for k, v in pairs(list) do
            if next(line) then
                local button = {text = k, callback_data = v}
                if admin_current_position == v then
                	button.text = '💡 ' .. k
                end
                table.insert(line, button)
                table.insert(keyboard.inline_keyboard, line)
                line = {}
            else
                local button = {text = k, callback_data = v}
                if admin_current_position == v:gsub('!', '') then
                	button.text = '💡 ' .. k
                end
                table.insert(line, button)
            end
        end
        if next(line) then
            table.insert(keyboard.inline_keyboard, line)
        end
    end
    local bottom_bar
    if admin then
		bottom_bar = {{text = 'User Commands', callback_data = 'user_commands'}}
	else
	    bottom_bar = {{text = 'Admin Commands', callback_data = 'admin_commands'}}
	end
	table.insert(bottom_bar, {text = 'Information', callback_data = 'fromhelp:about'})
	table.insert(keyboard.inline_keyboard, bottom_bar)
	return keyboard
end
local function do_keyboard_private()
    local keyboard = {}
    keyboard.inline_keyboard = {
    	{
    		{text = 'Official Channel', url = 'https://telegram.me/' .. config.channel:gsub('@', '')}
	    },
	    {
	        {text = 'All Commands', callback_data = 'user_commands'}
        }
    }
    return keyboard
end
local function do_keyboard_startme()
    local keyboard = {}
    keyboard.inline_keyboard = {
    	{
    		{text = 'Start Me', url = 'https://telegram.me/' .. bot.username}
	    }
    }
    return keyboard
end
local action = function(msg, blocks)
    if blocks[1] == 'start' then
        if msg.chat.type == 'private' then
            local message = get_helped_string('private'):format(msg.from.first_name:escape())
            local keyboard = do_keyboard_private()
            api.sendKeyboard(msg.from.id, message, keyboard, true)
        end
        return
    end
    if blocks[1] == 'help' then
    	if msg.chat.type == 'private' then
			local keyboard = make_keyboard()
			api.sendKeyboard(msg.from.id, get_helped_string('user_commands'), keyboard, true)
        end
    end
    if msg.cb then
        local query = blocks[1]
        local text
        if query == 'info_button' then
            local keyboard = do_keyboard_credits()
		    api.editMessageText(msg.chat.id, msg.message_id, 'Here are some useful links:', keyboard, true)
		    return
		end
        local with_admin_lines = true
        if query == 'user_commands' then
            text = get_helped_string('user_commands')
            with_admin_lines = false
        elseif query == 'admin_commands' then
            text = 'Tap on a button to see the *related commands*.'
        elseif query == 'group_information' then
        	text = get_helped_string('edit_group_information')
        elseif query == 'banhammer' then
        	text = get_helped_string('edit_banhammer')
        elseif query == 'flood_manager' then
        	text = get_helped_string('edit_flood_manager')
        elseif query == 'media_settings' then
        	text = get_helped_string('edit_media_settings')
        elseif query == 'welcome_settings' then
        	text = get_helped_string('edit_welcome_settings')
        elseif query == 'extra_commands' then
        	text = get_helped_string('edit_extra_commands')
        elseif query == 'warnings' then
        	text = get_helped_string('edit_warnings')
        elseif query == 'general_settings' then
        	text = get_helped_string('edit_general_settings')
        end
        local keyboard = make_keyboard(with_admin_lines, query)
        local res, code = api.editMessageText(msg.chat.id, msg.message_id, text, keyboard, true)
        if not res and code and code == 111 then
            api.answerCallbackQuery(msg.cb_id, 'You\'re already in this section.')
		elseif query == 'group_information' then
			api.answerCallbackQuery(msg.cb_id, 'Group Information')
		elseif query == 'banhammer' then
			api.answerCallbackQuery(msg.cb_id, 'Banhammer')
		elseif query == 'flood_manager' then
			api.answerCallbackQuery(msg.cb_id, 'Flood Manager')
		elseif query == 'media_settings' then
			api.answerCallbackQuery(msg.cb_id, 'Media Settings')
		elseif query == 'welcome_settings' then
			api.answerCallbackQuery(msg.cb_id, 'Welcome Settings')
		elseif query == 'extra_commands' then
			api.answerCallbackQuery(msg.cb_id, 'Extra Commands')
		elseif query == 'warnings' then
			api.answerCallbackQuery(msg.cb_id, 'Warnings')
		elseif query == 'general_settings' then
			api.answerCallbackQuery(msg.cb_id, 'General Settings')
        end
    end
end
return {
	action = action,
	admin_not_needed = true,
	triggers = {
	    config.cmd .. '(start)$',
	    config.cmd .. '(help)$',
	    '^###cb:(user_commands)$',
	    '^###cb:(admin_commands)$',
	    '^###cb:(group_information)$',
	    '^###cb:(banhammer)$',
	    '^###cb:(flood_manager)$',
	    '^###cb:(media_settings)$',
	    '^###cb:(welcome_settings)$',
	    '^###cb:(extra_commands)$',
	    '^###cb:(warnings)$',
	    '^###cb:(general_settings)$'
    }
}
