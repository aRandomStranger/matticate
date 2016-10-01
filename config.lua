return {
	bot_api_key = '',
	cmd = '/',
	db = 2,
	superadmins = {221714512},
	log = {
		chat = nil,
		admin = nil,
		stats = nil
	},
	bot_settings = {
		cache_time = {
			adminlist = 18000,
		},
		notify_bug = true,
		log_api_errors = true,
		stream_commands = true,
		admin_mode = false
	},
	groups = {
		['Off-Topic Geeks Chat'] = 'https://telegram.me/joinchat/DTcYUD8crPIOxTtEIyUCFQ',
		['International Off-Topic Geeks Chat'] = 'https://telegram.me/joinchat/DTcYUEBS0UIHm5Y-RYL1iA',
		['Off-Topic Idiots Chat'] = 'https://telegram.me/joinchat/DTcYUEARbHEcNIkkbOXM4w',
		['Bot Playground'] = 'https://telegram.me/joinchat/DTcYUD8dZJsFYa6tSaX1Og',
		['Programming Chat'] = 'https://telegram.me/joinchat/DTcYUD6hLJwiV2ryl3Ledg',
		['Memes'] = 'https://telegram.me/wwwmemes',
		['Music Chat'] = 'https://telegram.me/joinchat/DTcYUEEV1QZTxBFPtlAB8Q',
		['Geeks on Discord'] = 'https://discord.gg/ASAyPDB'
	},
	channel = '@mattata',
	source_code = 'https://github.com/matthewhesketh/matticate',
	plugins = {
		'onmessage.lua',
		'configure.lua',
		'menu.lua',
		'dashboard.lua',
		'banhammer.lua',
		'users.lua',
		'help.lua',
		'rules.lua',
		'service.lua',
		'links.lua',
		'warn.lua',
		'floodmanager.lua',
		'welcome.lua',
		'pin.lua',
		'mediasettings.lua',
		'private.lua',
		'admin.lua',
		'report.lua',
		'private_settings.lua',
		'extra.lua'
	},
	media_list = {
		'image',
		'audio',
		'video',
		'sticker',
		'gif',
		'voice',
		'contact',
		'file',
		'link'
	},
	chat_settings = {
		['settings'] = {
			['Welcome'] = 'on',
			['Extra'] = 'on',
			['Flood'] = 'off',
			['Silent'] = 'off',
			['Rules'] = 'off',
			['Reports'] = 'off'
		},
		['flood'] = {
			['MaxFlood'] = 5,
			['ActionFlood'] = 'kick'
		},
		['char'] = {
			['Arab'] = 'allowed',
			['Rtl'] = 'allowed'
		},
		['floodexceptions'] = {
			['text'] = 'no',
			['image'] = 'no',
			['video'] = 'no',
			['sticker'] = 'no',
			['gif'] = 'no'
		},
		['warnsettings'] = {
			['type'] = 'ban',
			['mediatype'] = 'ban',
			['max'] = 3,
			['mediamax'] = 2
		},
		['welcome'] = {
			['type'] = 'no',
			['content'] = 'no'
		},
		['media'] = {
			['image'] = 'ok',
			['audio'] = 'ok',
			['video'] = 'ok',
			['sticker'] = 'ok',
			['gif'] = 'ok',
			['voice'] = 'ok',
			['contact'] = 'ok',
			['file'] = 'ok',
			['link'] = 'ok',
			['TGlink'] = 'ok'
		},
		['tolog'] = {
			['ban'] = 'yes',
			['kick'] = 'yes',
			['warn'] = 'yes',
			['join'] = 'yes',
			['mediawarn'] = 'yes',
			['flood'] = 'yes'
		}
	},
	private_settings = {
		rules_on_join = 'off',
		reports = 'off'
	},
	chat_custom_texts = {'extra', 'info', 'links', 'warnings', 'mediawarn'},
	bot_keys = {
		d3 = {'bot:general', 'bot:usernames', 'bot:chat:latsmsg'},
		d2 = {'bot:groupsid', 'bot:groupsid:removed', 'tempbanned', 'bot:blocked', 'remolden_chats'}
	},
	api_errors = {
		[101] = 'NOT_ADMIN',
		[102] = 'USER_ADMIN_INVALID',
		[103] = 'SUPERGROUP_METHOD_ONLY',
		[104] = 'NOT_CREATOR',
		[105] = 'BAD_REQUEST',
		[106] = 'USER_NOT_PARTICIPANT',
		[107] = 'CHAT_ADMIN_REQUIRED',
		[108] = 'NO_ADMINS',
		[109] = 'INVALID_URL',
		[110] = 'PEER_ID_INVALID',
		[111] = 'MESSAGE_NOT_MODIFIED',
		[112] = 'MESSAGE_PARSE_ERROR',
		[113] = 'MIGRATED_TO_SUPERGROUP',
		[114] = 'MESSAGE_FORWARD_ERROR',
		[115] = 'EMPTY_MESSAGE',
		[116] = 'MESSAGE_NOT_FOUND',
		[117] = 'CHAT_NOT_FOUND',
		[118] = 'MESSAGE_TOO_LONG',
		[119] = 'USER_NOT_FOUND',
		[120] = 'KEYBOARD_PARSE_ERROR',
		[121] = 'KEYBOARD_ARRAY_ERROR',
		[122] = 'BUTTON_PARSE_ERROR',
		[123] = 'REPLY_MARKUP_EMPTY',
		[124] = 'QUERY_ID_INVALID',
		[125] = 'CHANNEL_PRIVATE',
		[126] = 'CALLBACK_TOO_LONG',
		[127] = 'INVALID_ID',
		[128] = 'TOTAL_TIMEOUT_ERROR',
		[129] = 'BUTTON_DATA_INVALID',
		[130] = 'FILE_METHOD_MISMATCH',
		[131] = 'MESSAGE_ID_INVALID',
		[132] = 'BUTTON_EMPTY',
		[133] = 'BUTTON_NOT_STRING',
		[134] = 'USER_ID_INVALID',
		[135] = 'CHAT_INVALID',
		[136] = 'USER_DEACTIVATED',
		[137] = 'KEYBOARD_PARSE_ERROR',
		[138] = 'MESSAGE_FORWARD_ERROR',
		[139] = 'BUTTON_NOT_STRING',
		[140] = 'INVALID_CHANNEL',
		[403] = 'BLOCKED_BY_USER',
		[429] = 'TOO_MANY_REQUESTS',
		[430] = 'TOO_MANY_CALLBACK_REQUESTS'
	}
}
