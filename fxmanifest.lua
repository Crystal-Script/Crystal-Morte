fx_version 'adamant'

game 'gta5'

author 'Alga11'

lua54 'yes'

client_scripts {
    'client/client.lua',
    
}

server_scripts {
    'server/*.lua',
    '@oxmysql/lib/MySQL.lua',
    '@mysql-async/lib/MySQL.lua',
    
}

shared_scripts {
    '@es_extended/imports.lua',
	'@ox_lib/init.lua',
    'config.lua'
}