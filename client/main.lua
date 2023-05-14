local onDuty = false
local carout = false
local balik = false
local rozvoz = false
local DeliveryZone = nil
local BoxCount = 0
ESX = exports["es_extended"]:getSharedObject()
lib.locale()

function DeleteNearestVehicle()
    local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 10.0, 0, 71)
    if DoesEntityExist(vehicle) then
        DeleteVehicle(vehicle)
        return true
    else
        return false
    end
end

function SpawnVehicle(model)
    local hash = GetHashKey(model)
    if not IsModelValid(hash) then
        Debug("Invalid model.")
        return
    end
    local spawnCoords = vector3(-974.3779, -1962.1353, 13.1916)
    local heading = 317.0751
    if IsAnyVehicleNearPoint(spawnCoords, 5.0) then
        return exports['okokNotify']:Alert(locale('NotifyTitle'), locale('SpawnPointOccupied'), 2500, 'warning')
    end
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(0)
    end
    local vehicle = CreateVehicle(hash, spawnCoords.x, spawnCoords.y, spawnCoords.z, heading, true, false)
    if DoesEntityExist(vehicle) then
        SetVehicleEngineOn(vehicle, true, true)
        SetVehicleOnGroundProperly(vehicle)
        exports['okokNotify']:Alert(locale('NotifyTitle'), locale('JobVehOut'), 2500, 'info')
        Debug("Spawned vehicle with net ID: " .. tostring(NetworkGetNetworkIdFromEntity(vehicle)))
         carout = true
        return true

    else
        Debug("Failed to spawn vehicle.")
         carout = false
        return false
    end
end

local OptionsCar = {
        {
            label = 'Vyparkovat služební vozidlo',
            icon = 'fa-solid fa-car',
            groups = 'gopostal',
            distance = 1.0,
            canInteract = function()
                return onDuty and not carout
            end,
           onSelect =  function(data)
           SpawnVehicle('speedo4')
           end
        },
        {
            label = 'Zaparkovat služební vozidlo',
            icon = 'fa-solid fa-car',
            groups = 'gopostal',
            distance = 1.0,
            canInteract = function()
                return onDuty and carout
            end,
           onSelect =  function(data)
           carout = false
           DeleteNearestVehicle()
           end
        },
}

local OptionsDuty = {
        {
            label = 'Jít do služby',
            icon = 'fa-solid fa-user',
            groups = 'gopostal',
            distance = 1.0,
            canInteract = function()
                return not onDuty
            end,
            onSelect = function(data)
            FreezeEntityPosition(PlayerPedId(), true)
                lib.progressBar({
                    duration = 2500,
                    label = 'Zapisuješ se do služby',
                    useWhileDead = false,
                    canCancel = false,
                    disable = {
                        car = true,
                    },
                })
                FreezeEntityPosition(PlayerPedId(), false)
                exports['okokNotify']:Alert(locale('NotifyTitle'), locale('Duty_On'), 2500, 'info')
                onDuty = true
            end
        },
        {
            icon = 'fa-solid fa-user',
            label = 'Odejít ze služby',
            groups = 'gopostal',
            distance = 1.0,
            canInteract = function()
                return onDuty
            end,
            onSelect = function(data)
                FreezeEntityPosition(PlayerPedId(), true)
                    lib.progressBar({
                        duration = 2500,
                        label = 'Zapisuješ si odchod ze služby',
                        useWhileDead = false,
                        canCancel = false,
                        disable = {
                            car = true,
                        },
                    })
                    FreezeEntityPosition(PlayerPedId(), false)
                    exports['okokNotify']:Alert(locale('NotifyTitle'), locale('Duty_Off'), 2500, 'info')
                    onDuty = false
            end
        }
}

Citizen.CreateThread(function()
lib.registerContext({
  id = 'GoPostalStartJobMenu',
  title = 'GoPostal Menu',
  options = {
    {
      title = 'Začít rozvážet lidem',
      description = 'Rozvážej balíčky a vydělej si nějaký ten drobák',
      icon = 'fa-money-bill',
      arrow = true,
      onSelect = function()
        if not rozvoz then
        if BoxCount > 0  then
        Debug(BoxCount)
            rozvoz = true
            StartDeliveryJob()
            exports['okokNotify']:Alert(locale('NotifyTitle'), "Začal jsi rozvážet balíčky, na mapě nalezneš lokaci kam se máš dostat", 2500, 'info')
            else
            exports['okokNotify']:Alert(locale('NotifyTitle'), "Nemáš v kufru dostatek balíčků", 2500, 'error')
        end
        end
       end
    },
        {
          title = 'Přestat rozvážet lidem',
          description = '',
          icon = 'fa-money-bill',
          arrow = true,
                onSelect = function()
                    if rozvoz then
                    if BoxCount < 1  then
                    Debug(BoxCount)
                     rozvoz = false
                     exports['okokNotify']:Alert(locale('NotifyTitle'), "Přestal jsi rozvážet balíčky", 2500, 'info')
                       lib.hideTextUI()
                     else  exports['okokNotify']:Alert(locale('NotifyTitle'), "Nemůžeš přestat rozvážet, v kufru máš ještě nějaké balíčky ty pako", 2500, 'warning')
                    end
                    end
                 end
        }
  }
})
end)

local OptionsToCar = {
        {
            label = 'Vložit Balíček do vozidla',
            icon = 'fa-solid fa-box',
            groups = 'gopostal',
            distance = 1.0,
            canInteract = function()
                 return  onDuty and carout and  balik
            end,
            onSelect = function(data)
                 balik = false
                 exports.ox_target:disableTargeting(true)
                 FreezeEntityPosition(PlayerPedId(), true)
                 lib.progressBar({
                                   duration = 2000,
                                   label = 'Vkládáš balíček do vozidla',
                                   useWhileDead = false,
                                   canCancel = false,
                                   disable = {
                                       car = true,
                                   },
                                   anim = {
                                       dict = 'mini@repair',
                                       clip = 'fixing_a_ped'
                                   },
                               })
                               DeleteEntity(boxProp)
                               BoxCount = BoxCount + 1
                               Debug(BoxCount)
                               lib.showTextUI(locale('have_boxes', BoxCount), {icon = 'box', style = { backgroundColor = '#ad3818', color = 'white', borderRadius = 20,}})
                              FreezeEntityPosition(PlayerPedId(), false)
                                exports.ox_target:disableTargeting(false)

            end
        },
        {
                    label = 'Vybrat Balíček z vozidla',
                    icon = 'fa-solid fa-box',
                    distance = 1.0,
                    groups = 'gopostal',
                    canInteract = function()
                         return  onDuty and carout and  not balik and BoxCount > 0
                    end,
                    onSelect = function(data)
                    Debug(BoxCount)
                         balik = false
                         FreezeEntityPosition(PlayerPedId(), true)
                         exports.ox_target:disableTargeting(true)
                         lib.progressBar({
                                           duration = 2000,
                                           label = 'Bereš balíček z vozidla',
                                           useWhileDead = false,
                                           canCancel = false,
                                           disable = {
                                               car = true,
                                           },
                                           anim = {
                                               dict = 'mini@repair',
                                               clip = 'fixing_a_ped'
                                           },
                                       })
                                       BoxCount = BoxCount - 1
                                       Debug(BoxCount)
                                       balik = true
                                      lib.showTextUI(locale('have_boxes', BoxCount), {icon = 'box', style = { backgroundColor = '#ad3818', color = 'white', borderRadius = 20,}})
                                       FreezeEntityPosition(PlayerPedId(), false)
                                      lib.requestAnimDict('anim@heists@box_carry@', 1000)
                                       TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 2.0, 2.5, -1, 49, 0, 0, 0, 0)
                                       lib.requestModel('prop_cs_cardbox_01', 1000)
                                       boxProp = CreateObject(GetHashKey('prop_cs_cardbox_01'), x, y, z, true, true, true)
                                       AttachEntityToEntity(boxProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 0x60F2), -0.1, 0.4, 0, 0, 90.0, 0, true, true, false, true, 5, true)
                                       exports.ox_target:disableTargeting(false)
                    end
                },
                {
                    label = 'GoPostal Menu',
                    icon = 'fa-solid fa-user',
                    distance = 1.0,
                    groups = 'gopostal',
                    canInteract = function()
                         return  onDuty and carout and  not balik and BoxCount > 0
                    end,
                    onSelect = function(data)
                         lib.showContext("GoPostalStartJobMenu")
                    end
                }
}

local OptionsVzitBalik = {
        {
            label = 'Vzít balík',
            icon = 'fa-solid fa-box',
            groups = 'gopostal',
            distance = 1.0,
            canInteract = function()
                return  onDuty and carout and not balik
            end,
           onSelect =  function(data)
           exports.ox_target:disableTargeting(true)
              balik = true
               FreezeEntityPosition(PlayerPedId(), true)
              lib.progressBar({
                  duration = 2000,
                  label = 'Přebíráš balík',
                  useWhileDead = false,
                  canCancel = false,
                  disable = {
                      car = true,
                  },
                  anim = {
                      dict = 'mini@repair',
                      clip = 'fixing_a_ped'
                  },
              })
               FreezeEntityPosition(PlayerPedId(), false)
                     lib.requestAnimDict('anim@heists@box_carry@', 1000)
                      TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 2.0, 2.5, -1, 49, 0, 0, 0, 0)
                      lib.requestModel('prop_cs_cardbox_01', 1000)
                      boxProp = CreateObject(GetHashKey('prop_cs_cardbox_01'), x, y, z, true, true, true)
                      AttachEntityToEntity(boxProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 0x60F2), -0.1, 0.4, 0, 0, 90.0, 0, true, true, false, true, 5, true)
                      exports.ox_target:disableTargeting(false)
              end
        },
}

local BalikDoAuta = exports.ox_target:addGlobalVehicle(OptionsToCar)

local duty   = exports.ox_target:addBoxZone({
    coords = vec3(-961.7448, -1981.4221, 14.4753),
    size = vec3(2, 2, 2),
    rotation = 45,
    debug = Config.Debug,
    options = OptionsDuty
})

local carspawn   = exports.ox_target:addBoxZone({
    coords = vec3(-978.5880, -1963.8387, 13.1916),
    size = vec3(2, 2, 2),
    rotation = 45,
    debug = Config.Debug,
    options = OptionsCar
})

local bratbalickydoauta   = exports.ox_target:addBoxZone({
    coords = vec3(68.9645, 127.8391, 79.6131),
    size = vec3(2, 16, 3),
    rotation = 70,
    debug = Config.Debug,
    options = OptionsVzitBalik
})

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
    return
  end
  DeleteEntity(boxProp)
  lib.hideTextUI()
  BoxCount = 0
 RemoveBlip(blip)
end)

function StartDeliveryJob()

local randomIndex = math.random(1, #Config.Locations)
local randomLocation = Config.Locations[randomIndex]

            local blip = AddBlipForCoord(randomLocation)
            SetBlipSprite(blip, 1)
            SetBlipColour(blip, 3)
            SetBlipRoute(blip, true)
                local pedModel = GetHashKey(Config.PedList[math.random(#Config.PedList)])
                if not IsModelValid(pedModel) or not IsModelAPed(pedModel) then
                    print("Invalid model")
                    return
                end
                RequestModel(pedModel)
                while not HasModelLoaded(pedModel) do
                    Wait(1)
                end
                local ped = CreatePed(4, pedModel, randomLocation.x, randomLocation.y, randomLocation.z, randomLocation.h, 1, 1)
                SetPedRandomComponentVariation(ped, true)
                SetModelAsNoLongerNeeded(pedModel)
               FreezeEntityPosition(ped, true)
               SetEntityInvincible(ped, true)
               SetBlockingOfNonTemporaryEvents(ped, true)

   balicek = exports.ox_target:addSphereZone({
       coords = vec3(randomLocation.x, randomLocation.y, randomLocation.z + 1.0),
       radius = 0.9,
       debug = Config.Debug,
       options = {{
                    name = 'balik',
                   label = 'Předat balík',
                   icon = 'fa-solid fa-box',
                   canInteract = function()
                       return  onDuty and carout and  balik
                   end,
                 onSelect = function(data)
                     exports.ox_target:disableTargeting(true)
                     FreezeEntityPosition(PlayerPedId(), true)
                     balik = false
                     Debug(BoxCount)
                     lib.progressBar({
                         duration = 2000,
                         label = 'Předáváš balík',
                         useWhileDead = false,
                         canCancel = false,
                         disable = {
                             car = true,
                         },
                        anim = {
                                    dict = 'mp_common',
                                    clip = 'givetake1_b',
                                },
                     })
                     DeleteEntity(ped)
                     DeleteEntity(boxProp)
                     RemoveBlip(blip)
                     exports.ox_target:removeZone(data.zone)

                     if BoxCount >= 1 then
                         Debug(BoxCount)
                         Wait(500)
                         exports['okokNotify']:Alert(locale('NotifyTitle'), "Na mapě máš nového zákazníka", 2500, 'info')
                         StartDeliveryJob()
                     end
                     if BoxCount < 1 then
                         exports['okokNotify']:Alert(locale('NotifyTitle'), "Nemáš už žádné balíčky, vrať se do depa a vyzvedni další balíčky", 2500, 'info')
                     end

                     FreezeEntityPosition(PlayerPedId(), false)
                     exports.ox_target:disableTargeting(false)
                 end,
                    distance = 2.3
       }}
   })

end