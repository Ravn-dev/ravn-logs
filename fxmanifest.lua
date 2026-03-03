fx_version 'cerulean'
game 'gta5'


author 'RaVn'
description 'Custom Logging Resource for QBox Servers'
version '1.0.0'

shared_scripts {
    'config.lua'
}

server_scripts {
    'server/main.lua',
    "server/discord.lua",
    'server/events.lua'
}

client_scripts {
    'client/client.lua'
}