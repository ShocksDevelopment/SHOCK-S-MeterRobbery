local searchedMeters = {}

local function DebugPrint(msg)
    if Config.Debug then
        print(('^2[parkingmeter]^7 %s'):format(msg))
    end
end

local function isOnCooldown(meterKey)
    local last = searchedMeters[meterKey]
    if not last then
        return false, 0
    end

    local remaining = Config.searchcooldown - (os.time() - last)
    if remaining > 0 then
        return true, remaining
    end

    return false, 0
end

RegisterNetEvent('parkingmeter:server:searchMeter', function(meterKey)
    local src = source

    if not meterKey or type(meterKey) ~= 'string' then
        DebugPrint(('Player %s sent invalid meter key'):format(src))
        return
    end

    local onCooldown, remaining = isOnCooldown(meterKey)
    if onCooldown then
        TriggerClientEvent('parkingmeter:client:notify', src, {
            title = 'Parking Meter',
            description = ('This meter is empty. Try again in %s seconds.'):format(remaining),
            type = 'error'
        })
        return
    end

    searchedMeters[meterKey] = os.time()

    local amount = math.random(Config.Reward.RewardMin, Config.Reward.RewardMax)

    if Config.UseOxinventory and Config.RewardItem ~= 'cash' then
        local success, response = exports.ox_inventory:AddItem(src, Config.RewardItem, amount)

        if not success then
            DebugPrint(('Failed to give %s x%s to player %s: %s'):format(Config.RewardItem, amount, src, response or 'unknown'))
            TriggerClientEvent('parkingmeter:client:notify', src, {
                title = 'Parking Meter',
                description = 'You found something, but could not carry it.',
                type = 'error'
            })
            return
        end

        DebugPrint(('Gave player %s item %s x%s'):format(src, Config.RewardItem, amount))
        TriggerClientEvent('parkingmeter:client:notify', src, {
            title = 'Parking Meter',
            description = ('You found %sx %s'):format(amount, Config.RewardItem),
            type = 'success'
        })
        return
    end

    -- QBCore cash reward
    local QBCore = exports['qb-core']:GetCoreObject()
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then
        DebugPrint(('Could not find player object for %s'):format(src))
        return
    end

    Player.Functions.AddMoney('cash', amount)

    DebugPrint(('Gave player %s $%s cash'):format(src, amount))
    TriggerClientEvent('parkingmeter:client:notify', src, {
        title = 'Parking Meter',
        description = ('You found $%s'):format(amount),
        type = 'success'
    })
end)