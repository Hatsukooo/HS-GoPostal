function Debug(msg)
    if Config.Debug then
        print(msg)
    end
end

function CreatePeds()
    for i=1, #Config.PedSpawn do
        local model = GetHashKey(Config.PedSpawn[i].model)
        local coords = Config.PedSpawn[i].coords
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end
        local ped = CreatePed(4, model, coords.x, coords.y, coords.z, coords.w, true, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, false)
    end
end

Citizen.CreateThread(function()
 CreatePeds()
 exports['blips']:addBlip('delivblip', 'GoPostal Sídlo', vec3(90.7632, 130.9322, 116.7332),{
 					blip = 441,
 					type = 4,
 					scale = 1.0,
 					color = 2,
 					})
end)


