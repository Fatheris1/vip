local isMenuOpen = false

local function toggleNui(bool, days, bonusRemaining, level)
    local playerName = GetPlayerName(PlayerId())

    isMenuOpen = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = 'toggle',
        display = bool,
        days = days or 0,
        bonusRemaining = bonusRemaining or 0,
        level = level or 1,
        name = playerName,
        locales = _L(Config.Locale)
    })
end

RegisterCommand('vip', function()
    ESX.TriggerServerCallback('fh-vip:checkVip', function(hasVip, level, days, bonusRemaining)
        if hasVip then
            toggleNui(true, days, bonusRemaining, level)
        else
            lib.notify({
                title = _U('vip_system'),
                description = _U('no_vip'),
                type = 'error'
            })
        end
    end)
end)

RegisterNUICallback('close', function(data, cb)
    toggleNui(false)
    cb('ok')
end)

RegisterNUICallback('a_1', function(data, cb)
    TriggerServerEvent('fh-vip:sv_a1')
    cb('ok')
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isMenuOpen then
            if IsControlJustReleased(0, 200) then -- ESC
                toggleNui(false)
            end
        else
            Citizen.Wait(500)
        end
    end
end)
