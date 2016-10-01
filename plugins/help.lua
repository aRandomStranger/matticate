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

I work at my best when I\'m an administrator in your group (otherwise I won't be able to kick or ban users)
]]
	elseif key == 'all' then
		return [[
*Commands for all users*:

/dashboard - Shows information about the specified group, in a private message.
/rules - Shows the group rules, in a private message.
/adminlist - Shows the admins of the specified group, in a private message.
/kickme - Kicks you from the group you execute the command in.
/about - Show some useful information.
/groups - Show the list of the discussion groups.
/help - Shows this message.
]]
	elseif key == 'mods_info' then
		return [[
*Admins | Information about the specified group*

/setrules <group rules> - Set (or update) rules for the group.
/setlink <link> - Set the link for the group. If the group is a public supergroup, you can just send /setlink.
/link - View the group's link.
/msglink - Get the link to a specified message. This only works in public supergroups.
]]
	elseif key == 'mods_banhammer' then
		return [[
*Admins | Banhammer Powers*

/kick <username/id> = Kicks the specified user from the group.
/ban <username/id> = Ban the specified user from the group.
/tempban <hours> = Ban the specified user for the given number of hours. This can only be executed via reply.
/unban <username/id> - Unban the specified user from the group.
/user <username/id> - Shows how many times the user has been banned in all matticate-administrated groups, and the warnings he/she has received.
/status <username/id> - Show the current status of the specified user.
]]
	elseif key == 'mods_flood' then
		return [[
*Admins | Flood Settings*

`/config` command, then `antiflood` button: manage the flood settings in private, with an inline keyboard. You can change the sensitivity, the action (kick/ban), and even set some exceptions.
`/antiflood [number]` = set how many messages a user can write in 5 seconds.
_Note_ : the number must be higher than 3 and lower than 26.
]]
	elseif key == 'mods_media' then
		return [[
*Admins | Media Settings*

`/config` command, then `media` button = receive via private message an inline keyboard to change all the media settings.
`/warnmax media [number]` = set the max number of warnings before be kicked/banned for have sent a forbidden media.
`/nowarns (by reply)` = reset the number of warnings for the users (*NOTE: both regular warnings and media warnings*).

*List of supported media*: _image, audio, video, sticker, gif, voice, contact, file, link, telegram.me links_
]]
	elseif key == 'mods_welcome' then
		return [[
*Admins | Welcome Settings*

`/config`, then `menu` tab = receive in private the menu keyboard. You will find an option to enable/disable welcome and goodbye messages.

*Custom welcome message*:
`/welcome Welcome $name, enjoy the group!`
Write after `/welcome` your welcome message. You can use some placeholders to include the name/username/id of the new member of the group
Placeholders:
`$username`: _will be replaced with the username_
`$name`: _will be replaced with the name_
`$id`: _will be replaced with the id_
`$title`: _will be replaced with the group title_
`$surname`: _will be replaced by the user's last name_
`$rules`: _will be replaced by a link to the rules of the group. Please read_ [here](https://telegram.me/GroupButler_beta/26) _how to use it, or you will get an error for sure_

*GIF/sticker as welcome message*
You can use a particular gif/sticker as welcome message. To set it, reply to the gif/sticker you want to set as welcome message with `/welcome`
]]
	elseif key == 'mods_extra' then
		return [[
*Admins | Extra Commands*

/extra <#trigger> <response> - Creates a custom #command in your group.
/extra list - Returns a list of all of your custom commands.
/extra del <#trigger> - Deletes the specified trigger.

For example, executing the command '/extra #ping Pong!' will configure me to reply with 'Pong!' every time somebody sends #ping in your group. This works with media too, by replying to the media with '/extra #trigger'.
]]
	elseif key == 'mods_warns' then
		return [[
*Admins | Warnings*

/warn <username/id> - Warn the specified user. Once the maximum number of warnings allowed is reached, he/she will be kicked/banned - depending on how you\'ve configured me for your group.

Use /user to view information about the specified user, including the amount of warns they have received.
]]
	elseif key == 'mods_chars' then
		return [[
*Admins | Special Characters*
]]
	elseif key == 'mods_pin' then
		return [[
*Admins | Pinned Message*

/pin <text>` - Sends the inputted text, Markdown-formatted, suitable to be pinned in your group.
/editpin <text> - Edit the previous text sent with /pin, for when sending a new large block of text would be inconvenient.
]]
	elseif key == 'mods_settings' then
		return [[
*Admins | Group Settings*

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
local function make_keyboard(mod, mod_current_position)
	local keyboard = {}
	keyboard.inline_keyboard = {}
	if mod then
	    local list = {
	        ['Banhammer'] = 'banhammer',
	        ['Group Info'] = 'info',
	        ['Flood Manager'] = 'flood',
	        ['Media Settings'] = 'media',
	        ['Welcome Settings'] = 'welcome',
	        ['General Settings'] = 'settings',
	        ['Extra Commands'] = 'extra',
	        ['Warnings'] = 'warnings',
	        ['Characters'] = 'char',
	        ['Pinned Message'] = 'pin'
        }
        local line = {}
        for k, v in pairs(list) do
            if next(line) then
                local button = {text = k, callback_data = v}
                if mod_current_position == v then
                	button.text = '💡 ' .. k
                end
                table.insert(line, button)
                table.insert(keyboard.inline_keyboard, line)
                line = {}
            else
                local button = {text = k, callback_data = v}
                if mod_current_position == v:gsub('!', '') then
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
    if mod then
		bottom_bar = {{text = 'User Commands', callback_data = 'user'}}
	else
	    bottom_bar = {{text = 'Admin Commands', callback_data = 'mod'}}
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
	        {text = 'All Commands', callback_data = 'user'}
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
			api.sendKeyboard(msg.from.id, get_helped_string('all'), keyboard, true)
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
        local with_mods_lines = true
        if query == 'user' then
            text = get_helped_string('all')
            with_mods_lines = false
        elseif query == 'mod' then
            text = 'Tap on a button to see the *related commands*.'
        elseif query == 'info' then
        	text = get_helped_string('mods_info')
        elseif query == 'banhammer' then
        	text = get_helped_string('mods_banhammer')
        elseif query == 'flood' then
        	text = get_helped_string('mods_flood')
        elseif query == 'media' then
        	text = get_helped_string('mods_media')
        elseif query == 'welcome' then
        	text = get_helped_string('mods_welcome')
        elseif query == 'extra' then
        	text = get_helped_string('mods_extra')
        elseif query == 'warnings' then
        	text = get_helped_string('mods_warns')
        elseif query == 'char' then
        	text = get_helped_string('mods_chars')
        elseif query == 'pin' then
        	text = get_helped_string('mods_pin')
        elseif query == 'settings' then
        	text = get_helped_string('mods_settings')
        end
        local keyboard = make_keyboard(with_mods_lines, query)
        local res, code = api.editMessageText(msg.chat.id, msg.message_id, text, keyboard, true)
        if not res and code and code == 111 then
            api.answerCallbackQuery(msg.cb_id, 'You\'re already in this section.')
		elseif query == 'info' then
			api.answerCallbackQuery(msg.cb_id, 'Admins | Group Information')
		elseif query == 'banhammer' then
			api.answerCallbackQuery(msg.cb_id, 'Admins | Banhammer Powers')
		elseif query == 'flood' then
			api.answerCallbackQuery(msg.cb_id, 'Admins | Anti-Flood Settings')
		elseif query == 'media' then
			api.answerCallbackQuery(msg.cb_id, 'Admins | Media Settings')
		elseif query == 'pin' then
			api.answerCallbackQuery(msg.cb_id, 'Admins | Pinned Message')
		elseif query == 'welcome' then
			api.answerCallbackQuery(msg.cb_id, 'Admins | Welcome Settings')
		elseif query == 'extra' then
			api.answerCallbackQuery(msg.cb_id, 'Admins | Extra Commands')
		elseif query == 'warnings' then
			api.answerCallbackQuery(msg.cb_id, 'Admins | Warnings')
		elseif query == 'char' then
			api.answerCallbackQuery(msg.cb_id, 'Admins | Special Characters')
		elseif query == 'settings' then
			api.answerCallbackQuery(msg.cb_id, 'Admins | Group Settings')
        end
    end
end
return {
	action = action,
	admin_not_needed = true,
	triggers = {
	    config.cmd .. '(start)$',
	    config.cmd .. '(help)$',
	    '^###cb:(user)$',
	    '^###cb:(mod)$',
	    '^###cb:(info)$',
	    '^###cb:(banhammer)$',
	    '^###cb:(flood)$',
	    '^###cb:(media)$',
	    '^###cb:(pin)$',
	    '^###cb:(welcome)$',
	    '^###cb:(extra)$',
	    '^###cb:(warnings)$',
	    '^###cb:(char)$',
	    '^###cb:(settings)$'
    }
}
