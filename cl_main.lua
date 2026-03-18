local function DebugPrint(msg)
    if Config.Debug then
        print(('^3[parkingmeter]^7 %s'):format(msg))
    end
end

local function GetMeterKey(coords)
    return ('%.2f_%.2f_%.2f'):format(coords.x, coords.y, coords.z)
end

local function LoadAnimDict(dict)
    RequestAnimDict(dict)

    local tries = 0
    while not HasAnimDictLoaded(dict) do
        Wait(50)
        tries = tries + 1

        if tries >= 100 then
            DebugPrint(('Failed to load anim dict: %s'):format(dict))
            return false
        end
    end

    return true
end

local function SearchMeter(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then
        DebugPrint('Invalid parking meter entity')
        return
    end

    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false) then
        lib.notify({
            title = 'Parking Meter',
            description = 'You cannot search a parking meter from a vehicle.',
            type = 'error'
        })
        return
    end

    local coords = GetEntityCoords(entity)
    local meterKey = GetMeterKey(coords)

    TaskTurnPedToFaceEntity(ped, entity, 750)
    Wait(750)

    local loaded = LoadAnimDict(Config.SearchAnim.dict)
    if loaded then
        TaskPlayAnim(
            ped,
            Config.SearchAnim.dict,
            Config.SearchAnim.clip,
            8.0,
            -8.0,
            -1,
            49,
            0.0,
            false,
            false,
            false
        )
    end

    local success = lib.progressCircle({
        duration = Config.searchtime * 1000,
        label = 'Searching parking meter...',
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true
        }
    })

    ClearPedTasks(ped)

    if not success then
        lib.notify({
            title = 'Parking Meter',
            description = 'Search cancelled.',
            type = 'error'
        })
        return
    end

    TriggerServerEvent('parkingmeter:server:searchMeter', meterKey)
end

CreateThread(function()
    if not Config.UseOxtarget then
        DebugPrint('ox_target disabled in config')
        return
    end

    Wait(1000)

    exports.ox_target:addModel(Config.Meterprops, {
        {
            name = 'search_parking_meter',
            icon = 'fa-solid fa-money-bill',
            label = 'Search Parking Meter',
            distance = 2.0,
            onSelect = function(data)
                SearchMeter(data.entity)
            end
        }
    })

    DebugPrint('Added ox_target interactions for parking meters')
end)

RegisterNetEvent('parkingmeter:client:notify', function(data)
    lib.notify(data)
end)