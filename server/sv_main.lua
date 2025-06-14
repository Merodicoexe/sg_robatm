ESX = exports["es_extended"]:getSharedObject()

function CountPolice()
    local policeCount = 0
    local players = ESX.GetExtendedPlayers()

    for _, xPlayer in pairs(players) do
        if xPlayer.job.name == 'police' then
            policeCount = policeCount + 1
        end
    end

    return policeCount
end

ESX.RegisterServerCallback('atm:countPolice', function(source, cb)
    cb(CountPolice())
end)

local rewardedPlayers = {}

lib.callback.register('atm:attemptRobbery', function(source, coords)
    local xPlayer = ESX.GetPlayerFromId(source)
    local policeCount = CountPolice()

    if rewardedPlayers[source] then
        --exports['sg_logs']:Log("Hráč použil Zakazanej trigger atm:attemptRobbery'", "cheater", src)
        exports["sg_bans"]:banPlayer(source, "Cheating detected / atm:attemptRobbery")
        return false -- 'You have been banned for attempting to re-run the ATM robbery event.'
    end

    if policeCount >= Config.Police then
        xPlayer.addMoney(5000) 

        -- Mark the player as rewarded
        rewardedPlayers[source] = true

        SetTimeout(Config.Cooldown * 60 * 1000, function()
            rewardedPlayers[source] = nil
        end)

        --Dispatch
        local data = {
            displayCode = '10-68',
            description = 'Vykradaní Bankomatu',
            isImportant = 0,
            recipientList = {'police', 'sheriff'},
            length = '10000',
            infoM = 'fa-info-circle',
            info = 'Vykradaní Bankomatu'
        }
    
        -- Get the player's current coordinates
        local playerPed = GetPlayerPed(source)
        local coords = GetEntityCoords(playerPed)
    
        -- Define the dispatch data
        local dispatchData = {
            dispatchData = data,
            caller = 'Alarm',
            coords = coords
        }
    
        -- Trigger the event with the dispatch data
        TriggerEvent('wf-alerts:svNotify', dispatchData)

        return true, 'Probíhá vykrádání bankomatu!'
    else
        return false, 'Not enough police online'
    end
end)

ESX.RegisterServerCallback('atm:checkItems', function(source, cb)
    local hasItem = false

    for _, item in ipairs(Config.RequestItem) do
        local itemCount = exports.ox_inventory:GetItemCount(source, item)
        if itemCount > 0 then
            hasItem = true
            break
        end
    end

    cb(hasItem)  -- Pokud má hráč alespoň 1x 'usb_blue', vrátí true
end)


RegisterCommand('debug_check', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if not xPlayer then
        print("Hráč nebyl nalezen.")
        return
    end

    for _, item in ipairs(Config.RequestItem) do
        local itemCount = exports.ox_inventory:GetItemCount(source, item)
        print("Hráč má " .. itemCount .. "x " .. item)
    end
end, false)
