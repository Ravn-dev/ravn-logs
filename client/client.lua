-- Ravn Logs (C) 2026 Ravn (Ravn-Dev)
-- Licensed under GNU GPLv3 (see LICENSE file)

local function DebugPrint(...)
    if Config.Debug then
        print('[ravn-logs DEBUG]', ...)
    end
end

if Config.LogWeaponFires then
    CreateThread(function()
        while true do
            Wait(5)
            local ped = PlayerPedId()

            if IsPedShooting(PlayerPedId()) then
                local weaponHash = GetSelectedPedWeapon(PlayerPedId())
                local coords = GetEntityCoords(ped)

                DebugPrint("Player ID", ped, "Detected weapon fire:", weaponHash, "Coords", coords.x, coords.y, coords.z)
                
                TriggerServerEvent('ravn-logs:weaponFired', weaponHash, coords.x, coords.y, coords.z)
                
                Wait(Config.WeaponFireCooldownMs)
            end
        end
    end)
end

-- Track last attacker (For All Death Logging)
local lastDamage = nil
local hasSentDeath = false

AddEventHandler('gameEventTriggered', function(name, args)
    local now = GetGameTimer()
    if name ~= 'CEventNetworkEntityDamage' then return end

    local victimPed   = args[1]
    local attackerEnt = args[2]

    if victimPed ~= PlayerPedId() then return end
    if not attackerEnt or attackerEnt == 0 then return end

    -- Resolve weapon properly
    local weaponHash = 0
    if args[7] and args[7] ~= 0 then
        weaponHash = args[7]
    end

    if weaponHash == 0 and IsEntityAPed(attackerEnt) then
        weaponHash = GetSelectedPedWeapon(attackerEnt)
    end

    -- Debug to see what values victimPed and attackerEnt are reporting as:
    DebugPrint("[ravn_logs DEBUG] victimPed:", victimPed, "attackerEnt:", attackerEnt, "weaponHash:", weaponHash, "Args weapon[5]:", args[5], "Args weapon[7]:", args[7], "GetSelectedPedWeapon-AttackerEnt:", GetSelectedPedWeapon(attackerEnt))
    
    -------------------------------------------------
    -- VEHICLE DAMAGE
    -------------------------------------------------
    if IsEntityAVehicle(attackerEnt) then
        local vehicle = attackerEnt
        local vehicleModel = GetEntityModel(vehicle)
        local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)

        local driverPed = GetPedInVehicleSeat(vehicle, -1)

        -- owner of the vehicle entity (fallback for when server cant find player cuz onesync and other plane of existance bs)
        local ownerPlayer = NetworkGetEntityOwner(vehicle) -- returns player index or -1

        if driverPed ~= 0 and DoesEntityExist(driverPed) and IsPedAPlayer(driverPed) then
            local attackerPlayer = NetworkGetPlayerIndexFromPed(driverPed)
            if attackerPlayer ~= -1 then
                lastDamage = {
                    sourceType    = "player_vehicle",
                    attackerId    = GetPlayerServerId(attackerPlayer),
                    vehicleEntity = vehicle,
                    vehicleModel  = vehicleModel,
                    vehicleName   = vehicleName,
                    weaponHash    = weaponHash
                }
            end
        elseif ownerPlayer and ownerPlayer ~= -1 then
            -- couldnt get driver but car is player owned so log player car info anyway
            lastDamage = {
                sourceType    = "player_vehicle",
                attackerId    = GetPlayerServerId(ownerPlayer),
                vehicleEntity = vehicle,
                vehicleModel  = vehicleModel,
                vehicleName   = vehicleName,
                weaponHash    = weaponHash
            }
        else
            -- npc / unowned / weirdness
            lastDamage = {
                sourceType    = (driverPed ~= 0 and DoesEntityExist(driverPed)) and "npc_vehicle" or "vehicle_no_driver",
                attackerId    = nil,
                vehicleEntity = vehicle,
                vehicleModel  = vehicleModel,
                vehicleName   = vehicleName,
                weaponHash    = weaponHash
            }
        end

        return
    end

    -------------------------------------------------
    -- Self Caused Death
    -------------------------------------------------
    if attackerEnt == victimPed then
        local playerServerId = GetPlayerServerId(PlayerId())
        local veh = GetVehiclePedIsIn(victimPed, false)
        local vehicleModel, vehicleName = nil, "Unknown"

        -- Only attach vehicle info if ped is in vehicle drivers seat
        if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == victimPed then
            vehicleModel = GetEntityModel(veh)
            vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)
            
            -- Self-inflicted death while in vehicle
            lastDamage = {
                sourceType    = "self_inflicted_vehicle",
                attackerId    = playerServerId,
                vehicleEntity = (veh ~= 0) and veh or nil,
                vehicleModel  = vehicleModel,
                vehicleName   = vehicleName,
                weaponHash    = weaponHash
            }
        else
            -- Normal self-inflicted death (not in vehicle)
            lastDamage = {
                sourceType    = "self_inflicted",
                attackerId    = playerServerId,
                vehicleEntity = nil,
                vehicleModel  = nil,
                vehicleName   = nil,
                weaponHash    = weaponHash
            }
        end
        
        return
    end

    -------------------------------------------------
    -- DAMAGE FROM PED (Vehicle)
    -------------------------------------------------
    if IsEntityAPed(attackerEnt) then

        if attackerEnt == victimPed then return end

        --  Check if ped is inside a vehicle
        local veh = GetVehiclePedIsIn(attackerEnt, false)

        local VEHICLE_WEAPONS = {
            [-1553120962] = true, -- WEAPON_RUN_OVER_BY_CAR
            [133987706]   = true, -- WEAPON_RAMMED_BY_CAR
            [539292904]   = true, -- WEAPON_VEHICLE_ROCKET
        }

        if veh ~= 0 
        and GetPedInVehicleSeat(veh, -1) == attackerEnt
        and (weaponHash == 0 or VEHICLE_WEAPONS[weaponHash]) then

            local vehicleModel = GetEntityModel(veh)
            local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel)
            local attackerPlayer = NetworkGetPlayerIndexFromPed(attackerEnt)

            if attackerPlayer ~= -1 then
                -- Player driving vehicle
                lastDamage = {
                    sourceType    = "player_vehicle",
                    attackerId    = GetPlayerServerId(attackerPlayer),
                    vehicleEntity = veh,
                    vehicleModel  = vehicleModel,
                    vehicleName   = vehicleName,
                    weaponHash    = weaponHash
                }
            else
                -- NPC driving vehicle
                lastDamage = {
                    sourceType    = "npc_vehicle",
                    attackerId    = nil,
                    vehicleEntity = veh,
                    vehicleModel  = vehicleModel,
                    vehicleName   = vehicleName,
                    weaponHash    = weaponHash
                }
            end

            return
        end

    -------------------------------------------------
    -- DAMAGE FROM PED (Gun / Melee / Etc)
    -------------------------------------------------

        local attackerPlayer = NetworkGetPlayerIndexFromPed(attackerEnt)

        -- Player attacker
        if attackerPlayer ~= -1 then
            lastDamage = {
                sourceType   = "player",
                attackerId   = GetPlayerServerId(attackerPlayer),
                vehicleEntity = nil,
                vehicleModel = nil,
                weaponHash   = weaponHash
            }
            return
        else
            -- NPC attacker
            lastDamage = {
                sourceType   = "npc",
                attackerId   = nil,
                vehicleEntity = nil,
                vehicleModel = nil,
                weaponHash   = weaponHash
            }
            return
        end
    end

    -------------------------------------------------
    -- ENVIRONMENT DAMAGE
    -------------------------------------------------
    if not attackerEnt or attackerEnt == 0 or attackerEnt == -1 then

        lastDamage = {
            sourceType   = "environment",
            attackerId   = nil,
            vehicleEntity = nil,
            vehicleModel = nil,
            weaponHash   = weaponHash,
            ts = now
        }
    end
end)

-- Death thread, send to server

CreateThread(function()
    while true do
        Wait(50)

        local ped = PlayerPedId()

        if IsEntityDead(ped) and not hasSentDeath then
            hasSentDeath = true

            if lastDamage then
                if Config.Debug then
                    print("[ravn-logs DEBUG] Sending death event to server:")
                    print(json.encode(lastDamage))
                end
                TriggerServerEvent('ravn_logs:playerDied', lastDamage)
            else
                if Config.Debug then
                    print("[ravn-logs DEBUG] Sending fallback environmental death")
                end
                TriggerServerEvent('ravn_logs:playerDied', {
                    sourceType = "environment",
                    weaponHash = 0
                })
            end

            lastDamage = nil
        end

        -- Reset only after full respawn (health restored)
        if hasSentDeath and not dead then
            local health = GetEntityHealth(ped)
            local maxHealth = GetEntityMaxHealth(ped)

            if health >= maxHealth - 10 then
                hasSentDeath = false
            end
        end
    end
end)

-- ==============================
-- F8 Command Logger Helper
-- ==============================
-- NOTE: "disconnect" and "quit" commands will not log since the client cannot trigger the server event before the game exits.
local f8Commands = { "test" } -- scalable Example: { "example", "hello", "test" }

for _, cmd in ipairs(f8Commands) do
    RegisterCommand(cmd, function()
        DebugPrint("[CLIENT] Logged command typed in F8")
        TriggerServerEvent("ravn_logs:f8Command", cmd)
    end, false)
end