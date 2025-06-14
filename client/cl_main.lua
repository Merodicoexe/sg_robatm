ESX = exports["es_extended"]:getSharedObject()
local PlayerData = {}
local lastRobbed = -1

Citizen.CreateThread(function()
    while ESX == nil do
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

local function SetupATMTargets()
    for _, atmModel in ipairs(Config.AvailableATMS) do
        exports.ox_target:addModel(atmModel, {
            {
                name = 'rob_atm',
                event = 'atm:rob',
                icon = 'fas fa-hand-holding-usd',
                label = 'Rob ATM',
                distance = 1.5,
            }
        })
    end
end

SetupATMTargets()

RegisterNetEvent('atm:rob')
AddEventHandler('atm:rob', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local currentTime = GetGameTimer() / 1000

    -- Check cooldown
    if (lastRobbed == -1 or (currentTime - lastRobbed) > (Config.Cooldown * 60)) then
        ESX.TriggerServerCallback('atm:countPolice', function(policeCount)
            if policeCount >= Config.Police then
                ESX.TriggerServerCallback('atm:checkItems', function(canRob)
                    if canRob then
                        exports["glow_minigames"]:StartMinigame(function(success)
                            if success then
                                lib.callback('atm:attemptRobbery', false, function(success, message)
                                    if success then
                                        lastRobbed = currentTime
                                        lib.notify({ title = 'Success', description = 'Úspěšně jste vykradli bankomat!', type = 'success' })
                                    else
                                        lib.notify({ title = 'Failed', description = message or 'Nelze vykrást bankomat', type = 'error' })
                                    end
                                end, playerCoords)
                            else
                                lib.notify({ title = 'Failed', description = 'Nepodařilo se vám vykrást bankomat', type = 'error' })
                            end
                        end, "spot")
                    else
                        lib.notify({ title = 'Missing Items', description = 'Nemáte požadované položky', type = 'error' })
                    end
                end)
            else
                lib.notify({ title = 'Police Required', description = 'Na internetu je málo policie', type = 'error' })
            end
        end)
    else
        lib.notify({ title = 'Cooldown', description = 'Tento bankomat byl nedávno vykraden, zkuste to znovu později', type = 'error' })
    end
end)
