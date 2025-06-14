fx_version 'cerulean'

game 'gta5'

author ''
description ''

shared_script 'config.lua'
shared_script '@es_extended/imports.lua'
shared_script '@ox_lib/init.lua'

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}

lua54 'yes'
