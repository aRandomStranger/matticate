local function action(msg, blocks)
    local old_db = 0
    local new_db = 2
    if blocks[1] == 'restorebot' then
        if not is_bot_owner(msg.from.id, true) then
        	return
        end
        local message = ''
        db:select(old_db)
        local d3_data = {}
        for _, hash in pairs(config.bot_keys.d3) do
            local t = db:hgetall(hash)
            if next(t) then
                d3_data[hash] = t
            else
                message = message .. 'Empty: ' .. hash .. '\n'
            end
        end
        local users = db:hvals('bot:usernames')
        local bans_info = {}
        for _, id in pairs(users) do
            local ban_data = db:hgetall('ban:' .. id)
            if next(ban_data) then
                bans_info[id] = ban_data
            end
        end
        db:select(new_db)
        for hash, content in pairs(d3_data) do
            message = message .. 'Restoring ' .. hash .. '...'
            local key_count = 0
            for key, val in pairs(content) do
                db:hset(hash, key, val)
                key_count = key_count + 1
            end
            message = message .. ' ' .. key_count .. ' keys restored\n'
        end
        api.sendMessage(msg.chat.id, message)
    end
    if blocks[1] == 'restore' then
        if msg.chat.type ~= 'private' then
            if roles.is_admin(msg) then
                local chat_id = msg.chat.id
                db:select(old_db)
                local old_data = {}
                local message = ''
                local warnings = db:hgetall('chat:' .. chat_id .. ':warnings')
                if next(warnings) then
                    old_data['warns'] = warnings
                else
                    message = message .. '- restoring [warnings]: empty\n'
                end
                local extra = db:hgetall('chat:' .. chat_id .. ':extra')
                if next(extra) then
                    old_data['extra'] = extra
                else
                    message = message .. '- restoring [extra]: empty\n'
                end
                local mediawarn = db:hgetall('chat:' .. chat_id .. ':mediawarn')
                if next(mediawarn) then
                    old_data['mediawarn'] = extra
                else
                    message = message..'- restoring [mediawarn]: empty\n'
                end
                local rules = db:get('chat:' .. chat_id .. ':rules')
                if not rules then
                	message = message..'- restoring [rules]: empty\n'
                end
                local about = db:get('chat:' .. chat_id .. ':about')
                if not about then
                	message = message .. '- restoring [about]: empty\n'
                end
                local welcome = db:hgetall('chat:' .. chat_id .. ':welcome')
                if not welcome then
                	message = message .. '- restoring [welcome]: empty\n'
                end
                vardump(old_data)
                db:select(new_db)
                for field, data in pairs(old_data) do
                    message = message .. '- restoring [' .. field .. ']: '
                    local key_count = 0
                    for key, val in pairs(data) do
                        db:hset('chat:' .. chat_id .. ':' .. field, key, val)
                        key_count = key_count + 1
                    end
                    message = message .. key_count .. ' key(s) restored\n'
                end
                if rules then
                    db:hset('chat:' .. chat_id .. ':info', 'rules', rules)
                    message = message .. '- restoring [rules]: done\n'
                end
                if about then
                    db:hset('chat:' .. chat_id .. ':info', 'about', about)
                    message = message .. '- restoring [about]: done\n'
                end
                if next(welcome) then
                    if welcome['type'] == 'media' or welcome['type'] == 'custom' then
                        for key, val in pairs(welcome) do
                            db:hset('chat:' .. chat_id .. ':welcome', key, val)
                        end
                        message = message .. '- restoring [about]: done\n'
                    end
                end
                api.sendMessage(msg.chat.id, message .. '\nDone.\nUse /config command to change the group settings')
            end
        end
    end
    db:select(config.db)
end
return {
    action = action,
    triggers = {
        config.cmd .. '(restorebot)$',
        config.cmd .. '(restore)$',
        config.cmd .. '(rst) (%d+)$'
    }
}