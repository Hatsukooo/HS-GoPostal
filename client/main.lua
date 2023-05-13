local onDuty = true
local carout = true
local balik = false
local rozvoz = true
local BoxCount = 0
ESX = exports["es_extended"]:getSharedObject()
lib.locale()

function DeleteNearestVehicle()
    local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 10.0, 0, 71)
    if DoesEntityExist(vehicle) then
        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteVehicle(vehicle)
        carout = false
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
    return  exports['okokNotify']:Alert(locale('NotifyTitle'), locale('SpawnPointOccupied'), 2500, 'warning')
    end
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Citizen.Wait(0)
    end
    local vehicle = CreateVehicle(hash, spawnCoords.x, spawnCoords.y, spawnCoords.z, heading, true, false)
    if DoesEntityExist(vehicle) then
    SetVehicleEngineOn(vehicle, true, true)
    SetVehicleOnGroundProperly(vehicle)
    carout = true
    exports['okokNotify']:Alert(locale('NotifyTitle'), locale('JobVehOut'), 2500, 'info')
        Debug("Spawned vehicle with net ID: " .. tostring(NetworkGetNetworkIdFromEntity(vehicle)))
    else
    carout = false
        Debug("Failed to spawn vehicle.")
    end

end

local OptionsCar = {
        {
            label = 'Vyparkovat služební vozidlo',
            icon = 'fa-solid fa-car',
            distance = 1.0,
            canInteract = function()
                return onDuty and not carout
            end,
           onSelect =  function(data)
           carout = true
           SpawnVehicle('speedo4')
           end
        },
        {
            label = 'Zaparkovat služební vozidlo',
            icon = 'fa-solid fa-car',
            distance = 1.0,
            canInteract = function()
                return onDuty and carout
            end,
           onSelect =  function(data)
           carout = false
           DeleteNearestVehicle()
           end
        },
       {
           label = 'Začít rozvážet balíky',
           icon = 'fa-solid fa-box',
           distance = 1.0,
           canInteract = function()
               return onDuty and carout and not rozvoz
           end,
          onSelect =  function(data)
            rozvoz = true
            exports['okokNotify']:Alert(locale('NotifyTitle'), locale('JobStarted'), 5000, 'info')
          end
       },
      {
          label = 'Přestat rozvážet',
          icon = 'fa-solid fa-box',
          distance = 1.0,
          canInteract = function()
              return onDuty and carout and  rozvoz
          end,
         onSelect =  function(data)
            rozvoz = false
            lib.hideTextUI()
            BoxCount = 0
            exports['okokNotify']:Alert(locale('NotifyTitle'), locale('JobEnded'), 5000, 'info')
         end
      },
}

local OptionsDuty = {
        {
            label = 'Jít do služby',
            event = 'HS-Job:Duty',
            icon = 'fa-solid fa-user',
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

local OptionsToCar = {
        {
            label = 'Vložit Balíček do vozidla',
            icon = 'fa-solid fa-box',
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
                               lib.showTextUI(locale('have_boxes', BoxCount))
                                FreezeEntityPosition(PlayerPedId(), false)
                                exports.ox_target:disableTargeting(false)
            end
        },
        {
                    label = 'Vybrat Balíček z vozidla',
                    icon = 'fa-solid fa-box',
                    distance = 1.0,
                    canInteract = function()
                         return  onDuty and carout and  not balik and BoxCount ~=0
                    end,
                    onSelect = function(data)
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
                                       balik = true
                                       lib.showTextUI(locale('have_boxes', BoxCount))
                                       FreezeEntityPosition(PlayerPedId(), false)
                                      lib.requestAnimDict('anim@heists@box_carry@', 1000)
                                       TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 2.0, 2.5, -1, 49, 0, 0, 0, 0)
                                       lib.requestModel('prop_cs_cardbox_01', 1000)
                                       boxProp = CreateObject(GetHashKey('prop_cs_cardbox_01'), x, y, z, true, true, true)
                                       AttachEntityToEntity(boxProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 0x60F2), -0.1, 0.4, 0, 0, 90.0, 0, true, true, false, true, 5, true)
                                       exports.ox_target:disableTargeting(false)
                    end
                }
}

local OptionsVzitBalik = {
        {
            label = 'Vzít balík',
            icon = 'fa-solid fa-box',
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
end)


lib.registerContext({
  id = 'GoPostalStartJobMenu',
  title = 'GoPostal Menu',
  options = {
    {
      title = 'Začít rozvážet lidem',
      description = '',
      icon = 'money',
      arrow = true,
    }
  }
})


local OptionsPredatBalik = {
        {
            label = 'Předat balík',
            icon = 'fa-solid fa-box',
            distance = 1.0,
            canInteract = function()
                return  onDuty and carout and  balik
            end,
           onSelect =  function(data)
                exports.ox_target:disableTargeting(true)
                  FreezeEntityPosition(PlayerPedId(), true)
                  balik = false
                  BoxCount = BoxCount - 1
                   lib.progressBar({
                       duration = 2000,
                       label = 'Předáváš balík',
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
                   exports.ox_target:disableTargeting(false)
                   DeleteEntity(boxProp)
              end
        },
}

CreateThread(function()
    for k, v in pairs(Config.Locations) do
        exports.ox_target:addSphereZone({
            coords = v.coords,
            radius = v.radius,
            debug = Config.Debug,
            options = OptionsPredatBalik,
         })
    end
end)