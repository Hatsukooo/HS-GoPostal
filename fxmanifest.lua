fx_version 'cerulean'
game 'gta5'
lua54 'yes'

Author 'Hatusko#0818'
Description 'Simple delivery script,  Working Duty, should not be glitchy and should work just fine'

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