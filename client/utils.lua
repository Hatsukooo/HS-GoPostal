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
end)
