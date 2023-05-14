ESX = exports["es_extended"]:getSharedObject()
lib.locale()

RegisterServerEvent('HS-GoPostalJob:AddMoney')
AddEventHandler('HS-GoPostalJob:AddMoney', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.name == 'gopostal' then
        local random = math.random(300, 4500)
        exports.ox_inventory:AddItem(xPlayer.source, 'money', random)
    end
end)


