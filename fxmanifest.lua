fx_version 'cerulean'
game 'gta5'
lua54 'yes'

client_scripts {
    'config.lua',
    'client/*.lua',
}

shared_scripts {
    '@ox_lib/init.lua'
}

server_scripts {
    'config.lua',
    'server/*.lua',
}

files {
    'locales/*.json'
  }