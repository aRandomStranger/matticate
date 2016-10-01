local function max_reached(chat_id, user_id)
    local max = tonumber(db:hget('chat:' .. chat_id .. ':warnsettings', 'mediamax')) or 2
    local n = tonumber(db:hincrby('chat:' .. chat_id .. ':mediawarn', user_id, 1))
    if n >= max then
        return true, n, max
    else
        return false, n, max
    end
end
local function is_ignored(chat_id, msg_type)
    local hash = 'chat:' .. chat_id .. ':floodexceptions'
    local status = (db:hget(hash, msg_type)) or 'no'
    if status == 'yes' then
        return true
    elseif status == 'no' then
        return false
    end
end
local function is_flooding_funct(msg)
    local spamhash = 'spam:' .. msg.chat.id .. ':' .. msg.from.id
    local msgs = tonumber(db:get(spamhash)) or 1
    local max_msgs = tonumber(db:hget('chat:' .. msg.chat.id .. ':flood', 'MaxFlood')) or 5
    if msg.cb then max_msgs = 15 end
    local max_time = 5
    db:setex(spamhash, max_time, msgs+1)
    if msgs > max_msgs then
        return true, msgs, max_msgs
    else
        return false
    end
end
local function is_blocked(id)
	if db:sismember('bot:blocked', id) then
		return true
	else
		return false
	end
end
local function onmessage(msg) 
    local msg_type = 'text'
    if msg.media then msg_type = msg.media_type end
    if not is_ignored(msg.chat.id, msg_type) then
        local is_flooding, msgs_sent, msgs_max = is_flooding_funct(msg)
        if is_flooding then
            local status = (db:hget('chat:' .. msg.chat.id .. ':settings', 'Flood')) or config.chat_settings['settings']['Flood']
            if status == 'on' and not msg.cb and not roles.is_admin_cached(msg) then
                local action = db:hget('chat:' .. msg.chat.id .. ':flood', 'ActionFlood')
                local name = misc.getname_final(msg.from)
                local res, message
                if action == 'ban' then
        	        res = api.banUser(msg.chat.id, msg.from.id)
        	    else
        	        res = api.kickUser(msg.chat.id, msg.from.id)
        	    end
        	    if res then
        	        misc.saveBan(msg.from.id, 'flood')
        	        if action == 'ban' then
        	            message = '%s has been banned for flooding chat.'
        	            message = message:format(name)
        	        else
        	            message = '%s has been kicked for flooding chat.'
        	            message = message:format(name)
        	        end
        	        if msgs_sent == (msgs_max + 1) or msgs_sent == msgs_max + 5 then
        	            api.sendMessage(msg.chat.id, message, true)
        	        end
        	    end
        	end
            if msg.cb then
                api.answerCallbackQuery(msg.cb_id, _("‼️ Please don't abuse the keyboard, requests will be ignored"))
            end
            return false
        end
    end
    if msg.media and not(msg.chat.type == 'private') and not msg.cb then
        local media = msg.media_type
        local hash = 'chat:' .. msg.chat.id .. ':media'
        local media_status = (db:hget(hash, media)) or 'ok'
        local out
        if not(media_status == 'ok') then
            if not roles.is_admin_cached(msg) then --ignore admins
                local name = misc.getname_final(msg.from)
                local max_reached_var, n, max = max_reached(msg.chat.id, msg.from.id)
    	        if max_reached_var then --max num reached. Kick/ban the user
    	            local status = (db:hget('chat:'..msg.chat.id..':warnsettings', 'mediatype')) or config.chat_settings['warnsettings']['mediatype']
    	            if status == 'kick' then
                        res = api.kickUser(msg.chat.id, msg.from.id)
                    elseif status == 'ban' then
                        res = api.banUser(msg.chat.id, msg.from.id)
    	            end
    	            if res then
    	                misc.saveBan(msg.from.id, 'media')
    	                db:hdel('chat:' .. msg.chat.id .. ':mediawarn', msg.from.id)
    	                local message
    	                if status == 'ban' then
			    			message = '%s was banned for sending forbidden media.'
			    			message = message:format(name)
    	                else
			    			message = '%s was kicked for sending forbidden media.'
			    			message = message:format(name)
    	                end
    	                api.sendMessage(msg.chat.id, message, true)
    	            end
	            else
			    	local message = '%s, this type of media isn\'t allowed in this group.'
			    	message = message:format(name)
	                api.sendReply(msg, message, true)
	            end
    	    end
    	end
    end
    
    local rtl_status = (db:hget('chat:' .. msg.chat.id .. ':char', 'Rtl')) or 'allowed'
    if rtl_status == 'kick' or rtl_status == 'ban' then
        local rtl = '‮'
        local last_name = 'x'
        if msg.from.last_name then last_name = msg.from.last_name end
        local check = msg.text:find(rtl..'+') or msg.from.first_name:find(rtl..'+') or last_name:find(rtl..'+')
        if check ~= nil and not roles.is_admin_cached(msg) then
            local name = misc.getname_final(msg.from)
            local res
            if rtl_status == 'kick' then
                res = api.kickUser(msg.chat.id, msg.from.id)
            elseif status == 'ban' then
                res = api.banUser(msg.chat.id, msg.from.id)
            end
    	    if res then
    	        misc.saveBan(msg.from.id, 'rtl') --save ban
    	        local message = '%s has been kicked for using forbidden characters.'
    	        message = message:format(name)
    	        if rtl_status == 'ban' then
					message = '%s has been banned for for using forbidden characters.'
					message = message:format(name)
    	        end
    	        api.sendMessage(msg.chat.id, message, true)
    	    end
        end
    end
    if msg.text and msg.text:find('([\216-\219][\128-\191])') then
        local arab_status = (db:hget('chat:' .. msg.chat.id .. ':char', 'Arab')) or 'allowed'
        if arab_status == 'kick' or arab_status == 'ban' then
    	    if not roles.is_admin_cached(msg) then
    	        local name = misc.getname_final(msg.from)
    	        local res
    	        if arab_status == 'kick' then
    	            res = api.kickUser(msg.chat.id, msg.from.id)
    	        elseif arab_status == 'ban' then
    	            res = api.banUser(msg.chat.id, msg.from.id)
    	        end
    	        if res then
    	            misc.saveBan(msg.from.id, 'arab')
    	            local message = '%s was kicked for using forbidden characters.'
    	            message = message:format(name)
    	            if arab_status == 'ban' then
						message = '%s was banned for using forbidden characters.'
						message = message:format(name)
    	            end
    	            api.sendMessage(msg.chat.id, message, true)
    	        end
            end
        end
    end
    if is_blocked(msg.from.id) then
        return false
    end
    return true
end
return {
    onmessage = onmessage
}