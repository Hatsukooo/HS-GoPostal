Config = {}
Config.Debug = false
Config.JobName = 'gopostal'
Config.NotificationType = okokNotify
Config.PedSpawn = {
    { model = 's_m_m_movspace_01', coords = vector4(53.4131, 114.8203, 78.1969, 326.4925) },
    { model = 's_m_m_movspace_01', coords = vector4(57.3836, 125.7354, 78.3044, 249.3264) },
}
Config.GlobalProgBarDur = 2500

Config.VehicleSpawnPoint = vec4(62.9860, 123.4960, 79.1768, 157.2110)

Config.TakeMailCoords = vec3(68.9865, 127.7311, 80.2123)
Config.TMBoxSize = vec3(2,16,4)
Config.TMProgressDur = 2500

Config.VehicleSpawnNPCCoords = vec4(57.3836, 125.7354, 79.3044, 249.3264)
Config.VSBoxSize = vec3(2,2,3)

Config.DutyNPCCoords = vec4(53.5766, 114.7477, 79.1972, 348.9567)
Config.DutyBoxSize = vec3(2,2,2)
Config.DutyProgressDur = 2500

Config.KeyToDropBox = 101 -- Key to drop the box from hands

Config.Locations = {
     vec4(892.4224, -540.9585, 57.5065, 115.0706),
     vec4(878.7080, -498.3229, 57.0906, 230.7386),
     vec4(808.4604, -164.0074, 74.8755, 155.0285),
     vec4(-7.4188, 409.4265, 110.1269, 77.0690),
     vec4(85.0307, 562.1121, 181.7731, 2.3873),
     vec4(119.3725, 564.6985, 182.9593, 6.2093),
     vec4(-1406.0778, 527.5571, 122.8312, 355.8425),
     vec4(-1453.8204, 512.2861, 116.7892, 130.00),
     vec4(-2008.1882, 367.1774, 93.8143, 268.4322),
    }

    Config.PedList = {
        "u_m_m_streetart_01",
        "s_m_y_garbage",
        "g_m_m_chiboss_01",
        "csb_bride",
        "cs_siemonyetarian",
        "cs_old_man1a",
        "cs_maryann",
        "cs_karen_daniels",
        "cs_amandatownley",
        "a_m_y_vinewood_01",
        "a_m_y_mexthug_01",
        "a_m_y_beach_03",
        "a_m_m_indian_01",
        "a_m_m_ktown_01",
        "a_m_m_genfat_01",
    }


function N(text, type)
    if Config.NotificationType == "ESX" then
        ESX.ShowNotification(text)
    elseif Config.NotificationType == "ox_lib" then
        if type == "1" then
            lib.notify({
                title = locale('NotifyTitle'),
                description = text,
                type = "inform"
            })
        elseif type == "2" then
            lib.notify({
                title = locale('NotifyTitle'),
                description = text,
                type = "error"
            })
        elseif type == "3" then
            lib.notify({
                title = locale('NotifyTitle'),
                description = text,
                type = "success"
            })
    elseif Config.NotificationType == "okokNotify" then
        if type == "1" then
        exports['okokNotify']:Alert(locale('NotifyTitle'), text, 5000, 'info')
        elseif type == "2" then
        exports['okokNotify']:Alert(locale('NotifyTitle'), text, 5000, 'success')
        elseif type == "3" then
        exports['okokNotify']:Alert(locale('NotifyTitle'), text, 5000, 'error')
        elseif Config.NotificationType == "custom" then
            print("add your notification system! in utils.lua")
        end
    end
end
end