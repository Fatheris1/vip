local function getVipData(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return nil end

    local identifier = xPlayer.getIdentifier()
    local result = MySQL.single.await('SELECT vip_level, last_daily, expiration FROM player_vip WHERE identifier = ?', {identifier})
    
    if result and result.vip_level > 0 then
        if result.expiration then
            local expirationTime = math.floor(result.expiration / 1000)
            local currentTime = os.time()
            
            if currentTime > expirationTime then
                -- VIP pasibaigė, ištriname arba nustatom lygį į 0
                MySQL.update('UPDATE player_vip SET vip_level = 0 WHERE identifier = ?', {identifier})
                return nil
            end
        end

        return {
            level = result.vip_level,
            last_daily = result.last_daily,
            expiration = result.expiration
        }
    end
    return nil
end

ESX.RegisterServerCallback('fh-vip:checkVip', function(source, cb)
    local data = getVipData(source)
    if data then
        local remainingDays = 0
        if data.expiration then
            local diff = math.floor(data.expiration / 1000) - os.time()
            remainingDays = math.ceil(diff / (24 * 3600))
        end

        local bonusRemaining = 0
        if data.last_daily then
            local lastDaily = math.floor(data.last_daily / 1000)
            local timeDiff = os.time() - lastDaily
            local twentyFourHours = 24 * 60 * 60
            if timeDiff < twentyFourHours then
                bonusRemaining = twentyFourHours - timeDiff
            end
        end

        cb(true, data.level, remainingDays, bonusRemaining)
    else
        cb(false, 0, 0, 0)
    end
end)

RegisterNetEvent('fh-vip:sv_a1', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local vipData = getVipData(src)

    if not vipData then
        print('^1[SECURITY ALERT] ^7Žaidėjas ^3' .. GetPlayerName(src) .. ' ^7bandė pasisavinti VIP bonusą be VIP statuso!^7')
        return
    end

    local identifier = xPlayer.getIdentifier()
    local lastDaily = 0
    if vipData.last_daily then
        lastDaily = math.floor(vipData.last_daily / 1000)
    end
    
    local timeDiff = os.time() - lastDaily
    local twentyFourHours = 24 * 60 * 60

    if timeDiff < twentyFourHours then
        local remaining = twentyFourHours - timeDiff
        local hours = math.floor(remaining / 3600)
        local minutes = math.floor((remaining % 3600) / 60)
        
        TriggerClientEvent('ox_lib:notify', src, {
            title = _U('vip_system'),
            description = _U('bonus_cooldown', hours, minutes),
            type = 'error'
        })
        return
    end

    local rewardData = Config.Rewards[vipData.level]
    if not rewardData then
        print('^1[ERROR] ^7Nerasta apdovanojimų konfigūracija VIP lygiui: ^3' .. vipData.level .. '^7')
        return
    end

    if rewardData.money > 0 then
        xPlayer.addMoney(rewardData.money)
    end

    if rewardData.items and #rewardData.items > 0 then
        for _, item in ipairs(rewardData.items) do
            if xPlayer.canCarryItem(item.name, item.count) then
                xPlayer.addInventoryItem(item.name, item.count)
            else
                TriggerClientEvent('ox_lib:notify', src, {
                    title = _U('vip_system'),
                    description = _U('no_inventory_space', item.name),
                    type = 'error'
                })
            end
        end
    end
    
    MySQL.update('UPDATE player_vip SET last_daily = CURRENT_TIMESTAMP WHERE identifier = ?', {identifier})
    
    TriggerClientEvent('ox_lib:notify', src, {
        title = _U('vip_system'),
        description = _U('bonus_claimed'),
        type = 'success'
    })
end)

ESX.RegisterCommand('setvip', Config.AdminGroup, function(xPlayer, args, showError)
    local target = args.playerId
    local level = args.level or 1
    local days = args.days or 30
    
    if target then
        local expirationDate = os.date('%Y-%m-%d %H:%M:%S', os.time() + (days * 24 * 60 * 60))
        
        MySQL.insert('INSERT INTO player_vip (identifier, vip_level, expiration) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE vip_level = ?, expiration = ?', {
            target.getIdentifier(), level, expirationDate, level, expirationDate
        }, function(id)
            TriggerClientEvent('ox_lib:notify', xPlayer.source, {
                title = _U('vip_system'),
                description = _U('setvip_admin', target.getName(), level, days),
                type = 'success'
            })
            
            TriggerClientEvent('ox_lib:notify', target.source, {
                title = _U('vip_system'),
                description = _U('setvip_target', days),
                type = 'success'
            })
        end)
    end
end, true, {help = _U('setvip_help'), arguments = {
    {name = 'playerId', help = _U('arg_playerid'), type = 'player'},
    {name = 'level', help = _U('arg_level'), type = 'number'},
    {name = 'days', help = _U('arg_days'), type = 'number'}
}})