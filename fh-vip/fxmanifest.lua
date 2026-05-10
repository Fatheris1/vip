fx_version 'cerulean'
game 'gta5'

author '.fatheris'
description 'VIP system'
version '1.0.0'

shared_scripts {
    'config.lua',
    'init_locales.lua',
    'locales/en.lua',
    'locales/lt.lua',
    '@es_extended/imports.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/style.css',
    'nui/script.js'
}