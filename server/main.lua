ESX = exports["es_extended"]:getSharedObject()
lib.locale()

RegisterServerEvent('HS-GoPostalJob:Pay')
AddEventHandler('HS-GoPostalJob:Pay', function()
    local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer.job.name == Config.JobName then
            local random = math.random(100, 500)
            exports.ox_inventory:AddItem(xPlayer.source, 'money', random)
        end
end)


