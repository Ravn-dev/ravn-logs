fx_version 'cerulean'
game 'gta5'


author 'RaVn'
description 'Custom Logging Resource for QBox Servers'
version '1.0.0'

ui_page 'web/dist/index.html'
nui_callback_strict_mode 'true'

files {
    'web/dist/index.html',
    'web/dist/assets/*'
}

shared_scripts {
    'config.lua'
}

server_scripts {
    'server/main.lua',
    'server/database.lua',
    "server/discord.lua",
    'server/viewer.lua',
    'server/events.lua'
}

client_scripts {
    'client/client.lua',
    'client/ui.lua'
}
