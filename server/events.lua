-- Ravn Logs (C) 2026 Ravn (Ravn-Dev)
-- Licensed under GNU GPLv3 (see LICENSE file)

local function baseLog(type, data)
    return {
        timestamp = os.time(),
        type = type,
        data = data
    }
end

-- =================
-- Global Functions
-- =================

-- Weapon hash lookup
local weaponNames = {
    
    -- Pistols
    [GetHashKey('WEAPON_PISTOL')]         = "Pistol",
    [GetHashKey('WEAPON_PISTOL_MK2')]     = "Pistol MK2",
    [GetHashKey('WEAPON_COMBATPISTOL')]   = "Combat Pistol",
    [GetHashKey('WEAPON_APPISTOL')]       = "AP Pistol",
    [GetHashKey('WEAPON_PISTOL50')]       = "Pistol .50",
    [GetHashKey('WEAPON_SNSPISTOL')]      = "SNS Pistol",
    [GetHashKey('WEAPON_SNSPISTOL_MK2')]  = "SNS Pistol MK2",    
    [GetHashKey('WEAPON_VINTAGEPISTOL')]  = "Vintage Pistol",
    [GetHashKey('WEAPON_REVOLVER')]       = "Heavy Revolver",
    [GetHashKey('WEAPON_REVOLVER_MK2')]   = "Heavy Revolver MK2",
    [GetHashKey('WEAPON_DOUBLEACTION')]   = "Double-Action Revolver",
    [GetHashKey('WEAPON_NAVYREVOLVER')]   = "Navy Revolver",
    [GetHashKey('WEAPON_HEAVYPISTOL')]    = "Heavy Pistol",
    [GetHashKey('WEAPON_MACHINEPISTOL')]  = "Machine Pistol",
    [GetHashKey('WEAPON_WM29PISTOL')]     = "WM 29 Pistol",
    [GetHashKey('WEAPON_GADGETPISTOL')]   = "Perico Pistol",
    [GetHashKey('WEAPON_MARKSMANPISTOL')] = "Marksman Pistol",
    [GetHashKey('WEAPON_RAYPISTOL')]      = "Up-n-Atomizer",

    -- SMGs / Rifles
    [GetHashKey('WEAPON_MICROSMG')]       = "Micro SMG",
    [GetHashKey('WEAPON_MINISMG')]        = "Mini SMG",
    [GetHashKey('WEAPON_SMG')]            = "SMG",
    [GetHashKey('WEAPON_SMG_MK2')]        = "SMG MK2",
    [GetHashKey('WEAPON_TECPISTOL')]      = "Tec Pistol",
    [GetHashKey('WEAPON_ASSAULTSMG')]     = "Assault SMG",
    [GetHashKey('WEAPON_ASSAULTRIFLE')]   = "Assault Rifle",
    [GetHashKey('WEAPON_CARBINERIFLE')]   = "Carbine Rifle",
    [GetHashKey('WEAPON_CARBINERIFLE_MK2')] = "Carbine Rifle MK2",
    [GetHashKey('WEAPON_TACTICALRIFLE')]  = "Tactical Rifle",
    [GetHashKey('WEAPON_BATTLERIFLE')]    = "Battle Rifle",
    [GetHashKey('WEAPON_SPECIALCARBINE')] = "Special Carbine",
    [GetHashKey('WEAPON_ADVANCEDRIFLE')]  = "Advanced Rifle",
    [GetHashKey('WEAPON_COMPACTRIFLE')]   = "Compact Rifle",
    [GetHashKey('WEAPON_COMBATPDW')]      = "Combat PDW",

    -- Shotguns
    [GetHashKey('WEAPON_DBSHOTGUN')]       = "Double Barrel Shotgun",
    [GetHashKey('WEAPON_PUMPSHOTGUN')]     = "Pump Shotgun",
    [GetHashKey('WEAPON_PUMPSHOTGUN_MK2')] = "Pump Shotgun MK2",
    [GetHashKey('WEAPON_SAWNOFFSHOTGUN')]  = "Sawn-Off Shotgun",
    [GetHashKey('WEAPON_ASSAULTSHOTGUN')]  = "Assault Shotgun",
    [GetHashKey('WEAPON_COMBATSHOTGUN')]   = "Combat Shotgun",
    [GetHashKey('WEAPON_BULLPUPSHOTGUN')]  = "Bullpup Shotgun",
    [GetHashKey('WEAPON_HEAVYSHOTGUN')]    = "Heavy Shotgun",
    [GetHashKey('WEAPON_AUTOSHOTGUN')]     = "Auto Shotgun",
    [GetHashKey('WEAPON_MUSKET')]          = "Musket",

    -- Snipers
    [GetHashKey('WEAPON_SNIPERRIFLE')]     = "Sniper Rifle",
    [GetHashKey('WEAPON_HEAVYSNIPER')]     = "Heavy Sniper",
    [GetHashKey('WEAPON_PRECISIONRIFLE')]  = "Precision Rifle",
    [GetHashKey('WEAPON_MARKSMANRIFLE')]   = "Marksman Rifle",
    [GetHashKey('WEAPON_MARKSMANRIFLE_MK2')] = "Marksman Rifle Mk II",

    -- Heavy
    [GetHashKey('WEAPON_RPG')]              = "RPG",
    [GetHashKey('WEAPON_GRENADELAUNCHER')]  = "Grenade Launcher",
    [GetHashKey('WEAPON_MINIGUN')]          = "Minigun",
    [GetHashKey('WEAPON_RAILGUN')]          = "Railgun",
    [GetHashKey('WEAPON_RAILGUNXM3')]       = "Railgun XM3",
    [GetHashKey('WEAPON_GRENADE')]          = "Grenade",
    [GetHashKey('WEAPON_MOLOTOV')]          = "Molotov",
    [GetHashKey('WEAPON_SNOWBALL')]         = "Snowball",
    [GetHashKey('WEAPON_STUNGUN')]          = "Stun Gun",

    -- Throwables
    [GetHashKey('WEAPON_STICKYBOMB')]       = "Sticky Bomb",
    [GetHashKey('WEAPON_PROXMINE')]         = "Proximity Mine",
    [GetHashKey('WEAPON_PIPEBOMB')]         = "Pipe Bomb",

    -- Melee
    [GetHashKey('WEAPON_BATTLEAXE')]        = "Battle Axe",
    [GetHashKey('WEAPON_KNUCKLE')]          = "Brass Knuckles",
    [GetHashKey('WEAPON_BAT')]              = "Baseball Bat",
    [GetHashKey('WEAPON_CROWBAR')]          = "Crowbar",
    [GetHashKey('WEAPON_DAGGER')]           = "Dagger",
    [GetHashKey('WEAPON_FLASHLIGHT')]       = "Flashlight",
    [GetHashKey('WEAPON_GOLFCLUB')]         = "Golf Club",
    [GetHashKey('WEAPON_HAMMER')]           = "Hammer",
    [GetHashKey('WEAPON_HATCHET')]          = "Hatchet",
    [GetHashKey('WEAPON_STONE_HATCHET')]    = "Stone Hatchet",
    [GetHashKey('WEAPON_KNIFE')]            = "Knife",
    [GetHashKey('WEAPON_NIGHTSTICK')]       = "Night Stick",
    [GetHashKey('WEAPON_MACHETE')]          = "Machete",
    [GetHashKey('WEAPON_SWITCHBLADE')]      = "Switchblade",
    [GetHashKey('WEAPON_WRENCH')]           = "Wrench",
    [GetHashKey('WEAPON_BOTTLE')]           = "Broken Bottle",
    [GetHashKey('WEAPON_POOLCUE')]          = "Pool Cue",

    -- Special / Misc
    [GetHashKey('WEAPON_FLARE')]            = "Flare",
    [GetHashKey('WEAPON_FLAREGUN')]         = "Flare Gun",
    [GetHashKey('WEAPON_BZGAS')]            = "BZ Gas",
    [GetHashKey('WEAPON_SMOKEGRENADE')]     = "Smoke Grenade",
    [GetHashKey('WEAPON_PETROLCAN')]        = "Petrol Can",
    [GetHashKey('WEAPON_FIREEXTINGUISHER')] = "Fire Extinguisher",

    -- Other (Damage Causes)
    [GetHashKey('WEAPON_UNARMED')] = "Unarmed",
    [539292904]  = "Explosion (Generic)",
    [-1660422300] = "Fall",
    [615608432]  = "Fire",
}

-- Weapon Hash Lookup Function (Uses table above)
local function getWeaponName(hash)
    return weaponNames[hash] or tostring(hash)
end

-- ==============================
-- Player Joined
-- ==============================
AddEventHandler('playerJoining', function()
    if not Config.LogPlayerJoin then return end

    local src = source
    local playerName = GetPlayerName(src)
    local identifiers = GetSafeIdentifiers(src)

    if Config.Debug then
        DebugPrint('[SERVER] Player Joined:', playerName)
    end

    -- NDJSON Logging
    WriteLog(baseLog('player_join', {
        id = src,
        name = playerName,
        identifiers = GetSafeIdentifiers(src)
    }))

    -- Discord Logging
    if Config.DiscordLogs and Config.DiscordLogs.player_join then
        local message = string.format("Player Joined: %s (ID: %d)\nIdentifiers: %s", 
            playerName, src, table.concat(GetSafeIdentifiers(src), ", "))
        
        LogToDiscord('player_join', nil,{
            title = "Player Joined",
            color = 50944, -- Green (Color is Decimal Number)
            fields = {
                {
                    name = "Player",
                    value = string.format("%s (ID: %d)", playerName, src),
                    inline = true
                },
                {
                    name = "Identifiers",
                    value = table.concat(identifiers, "\n"),
                    inline = false
                }
            }
        })
    end
end)

-- ==============================
-- Player Dropped
-- ==============================
AddEventHandler('playerDropped', function(reason)
    if not Config.LogPlayerDisconnect then return end

    local src = source

    if Config.Debug then
        DebugPrint('[SERVER] Player Disconnected:', GetPlayerName(src))
    end

    -- NDJSON Logging
    WriteLog(baseLog('player_disconnected', {
        id = src,
        name = GetPlayerName(src),
        identifiers = GetSafeIdentifiers(src),
        reason = reason
    }))

    -- Discord Logging
    if Config.DiscordLogs and Config.DiscordLogs.player_disconnect then
        local src = source
        local playerName = GetPlayerName(src)
        local identifiers = GetSafeIdentifiers(src)

        LogToDiscord('player_disconnect', nil,{
            title = "Player Disconnected",
            color = 14811136, -- Red (Color is Decimal Number)
            fields = {
                {
                    name = "Player",
                    value = string.format("%s (ID: %d)", playerName, src),
                    inline = true
                },
                {
                    name = "Disconnect Reason",
                    value = reason or "Unknown",
                    inline = true
                },
                {
                    name = "Identifiers",
                    value = table.concat(identifiers, "\n"),
                    inline = false
                }
            }
        })
    end
end)

-- ==============================
-- Player Death Resolver
-- ==============================

RegisterNetEvent('ravn_logs:playerDied', function(damageData)
    local src = source
    local now = os.time() * 1000 -- server timestamp in ms

    if damageData then
        damageData.timestamp = now -- assign timestamp on server
    end

    -- Debug
    if Config.Debug then
        print("NOW:", now)
        print("DAMAGE TIME:", damageData.timestamp)
        print("DIFF:", damageData.timestamp and (now - damageData.timestamp) or "nil timestamp")
    end

    -------------------------------------------------
    -- VEHICLE KILL
    -------------------------------------------------
    if damageData.sourceType 
    and (damageData.sourceType == "vehicle" 
    or damageData.sourceType == "npc_vehicle") 
    or damageData.sourceType == "player_vehicle" then

        return HandleVehicleKill(src, damageData)
    end

    -------------------------------------------------
    -- PLAYER KILL (PvP)
    -------------------------------------------------
    if damageData.sourceType == "player" then
        return HandlePvPKill(src, damageData)
    end

    -------------------------------------------------
    -- NPC Kill
    -------------------------------------------------
    if damageData.sourceType == "npc" then
        return LogEnvironmentalDeath(src, "Killed by NPC")
    end

    -------------------------------------------------
    -- Self Infliceted Death
    -------------------------------------------------
    --Self Inflicted Vehicle Deaths
    if damageData.sourceType == "self_inflicted_vehicle" then
            return HandleSelfInflictedVeh(src, damageData)
        end
        
        if damageData.sourceType == "self_inflicted" then
            return HandleSelfInflicted(src, damageData)
        end
    -------------------------------------------------
    -- Environment
    -------------------------------------------------
    return LogEnvironmentalDeath(src)
end)

    -------------------------------------------------
    -- Vehicle Kill Handler
    -------------------------------------------------
function HandleVehicleKill(src, damageData)
    if not Config.LogVehicleDeaths then return end

    local victimName = GetPlayerName(src)
    local ped = GetPlayerPed(src)
    local coords = ped and GetEntityCoords(ped) or vector3(0,0,0)

    local killerId = damageData.attackerId
    local vehicleModel = damageData.vehicleModel

    local vehicleName = damageData.vehicleName or "Unknown"

    -- NDJSON Logging
    WriteLog(baseLog('player_killed_vehicle', {
        victim = {
            id = src,
            name = victimName,
            identifiers = GetSafeIdentifiers(src),
            coords = { x=coords.x, y=coords.y, z=coords.z }
        },
        killer = {
            id = killerId,
            name = killerId and GetPlayerName(killerId) or "NPC",
            identifiers = (killerId and GetSafeIdentifiers(killerId)) or {},
            vehicle = vehicleName,
            vehicle_hash = vehicleModel
        }
    }))

    -- Discord Logging
    if Config.DiscordLogs and Config.DiscordLogs.player_killed_vehicle then
        local killerName = killerId and GetPlayerName(killerId) or "NPC"
        local killerIdentifiers = killerId and GetSafeIdentifiers(killerId) or {}
        local victimIdentifiers = GetSafeIdentifiers(src)

        LogToDiscord('player_killed_vehicle', nil, {
            title = "Player Killed by Vehicle",
            color = 15158332, -- Red
            fields = {
                {
                    name = "Victim",
                    value = string.format(
                        "%s (ID: %d)\nCoords: %.2f, %.2f, %.2f",
                        victimName,
                        src,
                        coords.x, coords.y, coords.z
                    ),
                    inline = false
                },
                {
                    name = "Victim Identifiers",
                    value = table.concat(victimIdentifiers, "\n"),
                    inline = false
                },
                {
                    name = "Killer",
                    value = string.format(
                        "%s (ID: %s)",
                        killerName,
                        killerId or "N/A"
                    ),
                    inline = true
                },
                {
                    name = "Vehicle",
                    value = string.format(
                        "Model: %s",
                        vehicleName or "Unknown",
                        vehicleModel or "Unknown"
                    ),
                    inline = true
                },
                {
                    name = "Killer Identifiers",
                    value = killerId and table.concat(killerIdentifiers, "\n") or "NPC Vehicle",
                    inline = false
                }
            }
        })
    end
end

    -------------------------------------------------
    -- Player Kill Handler
    -------------------------------------------------
function HandlePvPKill(src, damageData)
    if not Config.LogPvP then return end

    local victimName = GetPlayerName(src)
    local killerId   = damageData.attackerId

    if not killerId then
        return LogEnvironmentalDeath(src)
    end

    local killerName = GetPlayerName(killerId)
    -- Convert weapon hash to human-readable name
    local weaponName = getWeaponName(damageData.weaponHash)

    -- NDJSON Logging
    WriteLog(baseLog('player_killed', {
        victim = {
            id = src,
            name = victimName,
            identifiers = GetSafeIdentifiers(src)
        },
        killer = {
            id = killerId,
            name = killerName,
            identifiers = GetSafeIdentifiers(killerId)
        },
        weapon = weaponName
    }))

    -- Discord Logging
    if Config.DiscordLogs and Config.DiscordLogs.player_killed then
        local victimIdentifiers = GetSafeIdentifiers(src)
        local killerIdentifiers = GetSafeIdentifiers(killerId)

        local ped = GetPlayerPed(src)
        local coords = ped and GetEntityCoords(ped) or vector3(0,0,0)

        LogToDiscord('player_killed', nil, {
            title = "Player Killed (PvP)",
            color = 15158332, -- Red
            fields = {
                {
                    name = "Victim",
                    value = string.format(
                        "%s (ID: %d)\nCoords: %.2f, %.2f, %.2f",
                        victimName,
                        src,
                        coords.x, coords.y, coords.z
                    ),
                    inline = false
                },
                {
                    name = "Victim Identifiers",
                    value = table.concat(victimIdentifiers, "\n"),
                    inline = false
                },
                {
                    name = "Killer",
                    value = string.format(
                        "%s (ID: %d)",
                        killerName,
                        killerId
                    ),
                    inline = false
                },
                {
                    name = "Weapon",
                    value = weaponName or "Unknown",
                    inline = true
                },
                {
                    name = "Killer Identifiers",
                    value = table.concat(killerIdentifiers, "\n"),
                    inline = false
                }
            }
        })
    end
end

    -------------------------------------------------
    -- Self Infliceted Death Handler (In Vehicle)
    -------------------------------------------------
function HandleSelfInflictedVeh(src, damageData)
    if not Config.LogSelfDeathVeh then return end
        
    local victimName = GetPlayerName(src)
    local killerId   = damageData.attackerId
    local weaponName = getWeaponName(damageData.weaponHash)
    local vehicleModel = damageData.vehicleModel
    local vehicleName = damageData.vehicleName or "Unknown"

    -- NDJSON Logging
    WriteLog(baseLog('Self_Inflicted_Vehicle_Death', {
        victim = {
            id = src,
            name = victimName,
            identifiers = GetSafeIdentifiers(src)
        },
        weapon = weaponName,
        vehicle = vehicleName,
        vehicle_hash = vehicleModel
    }))

    -- Discord Logging
    if Config.DiscordLogs and Config.DiscordLogs.self_inflicted_vehicle then
        local victimIdentifiers = GetSafeIdentifiers(src)
        local killerIdentifiers = GetSafeIdentifiers(killerId)

        local ped = GetPlayerPed(src)
        local coords = ped and GetEntityCoords(ped) or vector3(0,0,0)

        LogToDiscord('self_inflicted_vehicle', nil, {
            title = "Self Inflicted Vehicle Death",
            color = 15158332, -- Red
            fields = {
                {
                    name = "Victim",
                    value = string.format(
                        "%s (ID: %d)\nCoords: %.2f, %.2f, %.2f",
                        victimName,
                        src,
                        coords.x, coords.y, coords.z
                    ),
                    inline = false
                },
                {
                    name = "Victim Identifiers",
                    value = table.concat(victimIdentifiers, "\n"),
                    inline = false
                },
                {
                    name = "Weapon",
                    value = weaponName or "Unknown",
                    inline = true
                },
                                {
                    name = "Vehicle",
                    value = string.format(
                        "Model: %s",
                        vehicleName or "Unknown",
                        vehicleModel or "Unknown"
                    ),
                    inline = true
                }
            }
        })
    end
end

    -------------------------------------------------
    -- Self Infliceted Death Handler (Out of Vehicle)
    -------------------------------------------------
function HandleSelfInflicted(src, damageData)
    if not Config.LogSelfDeath then return end
        
    local victimName = GetPlayerName(src)
    local killerId   = damageData.attackerId
    local weaponName = getWeaponName(damageData.weaponHash)

    -- NDJSON Logging
    WriteLog(baseLog('Self_Inflicted_Death', {
        victim = {
            id = src,
            name = victimName,
            identifiers = GetSafeIdentifiers(src)
        },
        weapon = weaponName,
    }))

    -- Discord Logging
    if Config.DiscordLogs and Config.DiscordLogs.self_inflicted_death then
        local victimIdentifiers = GetSafeIdentifiers(src)
        local killerIdentifiers = GetSafeIdentifiers(killerId)

        local ped = GetPlayerPed(src)
        local coords = ped and GetEntityCoords(ped) or vector3(0,0,0)

        LogToDiscord('self_inflicted_death', nil, {
            title = "Self Inflicted Death",
            color = 15158332, -- Red
            fields = {
                {
                    name = "Victim",
                    value = string.format(
                        "%s (ID: %d)\nCoords: %.2f, %.2f, %.2f",
                        victimName,
                        src,
                        coords.x, coords.y, coords.z
                    ),
                    inline = false
                },
                {
                    name = "Victim Identifiers",
                    value = table.concat(victimIdentifiers, "\n"),
                    inline = false
                },
                {
                    name = "Weapon",
                    value = weaponName or "Unknown",
                    inline = true
                },
            }
        })
    end
end

    -------------------------------------------------
    -- Environment Handler
    -------------------------------------------------
function LogEnvironmentalDeath(src, reason)
    if not Config.LogDeaths then return end

    local playerName = GetPlayerName(src)
    local ped = GetPlayerPed(src)
    local coords = ped and GetEntityCoords(ped) or vector3(0,0,0)

    -- NDJSON Logging
    WriteLog(baseLog('player_death', {
        victim = {
            id = src,
            name = playerName,
            identifiers = GetSafeIdentifiers(src),
            coords = { x=coords.x, y=coords.y, z=coords.z }
        },
        killer = nil,
        reason = reason or "Environment"
    }))

    -- Discord Logging
    if Config.DiscordLogs and Config.DiscordLogs.player_death then
    local identifiers = GetSafeIdentifiers(src)

        LogToDiscord('player_death', nil, {
            title = "Environmental Death",
            color = 15105570, -- Orange (different from PvP red)
            fields = {
                {
                    name = "Player",
                    value = string.format(
                        "%s (ID: %d)\nCoords: %.2f, %.2f, %.2f",
                        playerName,
                        src,
                        coords.x, coords.y, coords.z
                    ),
                    inline = true
                },
                {
                    name = "Reason",
                    value = reason or "Bleed or Environment",
                    inline = true
                },
                {
                    name = "Identifiers",
                    value = table.concat(identifiers, "\n"),
                    inline = false
                }
            }
        })
    end
end

-- =========================
-- Weapon Fired
-- =========================
-- NormalizeCoords(coords)
local function NormalizeCoords(coords)
    if not coords then
        return vector3(0.0, 0.0, 0.0)
    end

    -- Works for vector3 userdata AND tables
    if coords.x ~= nil and coords.y ~= nil and coords.z ~= nil then
        return vector3(
            tonumber(coords.x) or 0.0,
            tonumber(coords.y) or 0.0,
            tonumber(coords.z) or 0.0
        )
    end

    return vector3(0.0, 0.0, 0.0)
end

-- Weapon Fired Logging
RegisterNetEvent('ravn-logs:weaponFired', function(weaponHash, x, y, z)
    if not Config.LogWeaponFires then return end

    local src = source
    local playerName = GetPlayerName(src)
    local playerIdentifiers = GetSafeIdentifiers(src)
    -- Convert hash to human-readable name
    local weaponName = getWeaponName(weaponHash)
    local coords = { x = x, y = y, z = z }
    local normalizedCoords = NormalizeCoords(coords)

    if Config.Debug then
        if coords then
            DebugPrint('[SERVER] Player ID', src, 'Weapon fired:', weaponName,
                'coords', coords.x, coords.y, coords.z)
        else
            DebugPrint('[SERVER] Player ID', src, 'Weapon fired:', weaponName,
                'coords', 'nil')
        end
    end

    -- NDJSON Logging
    WriteLog(baseLog('weapon_fired', {
        id = src,
        identifiers = playerIdentifiers,
        name = GetPlayerName(src),
        weapon = weaponName,
        location = {
            x = normalizedCoords.x,
            y = normalizedCoords.y,
            z = normalizedCoords.z
        }
    }))

    -- Discord Logging
    if Config.DiscordLogs and Config.DiscordLogs.weapon_fired then
        local playerIdentifiers = GetSafeIdentifiers(src)

        LogToDiscord('weapon_fired', nil, {
            title = "Weapon Fired",
            color = 3447003, -- blue
            fields = {
                {
                    name = "Player",
                    value = string.format("%s (ID: %d)", playerName, src),
                    inline = true
                },
                {
                    name = "Weapon",
                    value = weaponName,
                    inline = true
                },
                {
                    name = "Identifiers",
                    value = (#playerIdentifiers > 0 and table.concat(playerIdentifiers, "\n") or "N/A"),
                    inline = false
                },
                {
                    name = "Shooter Location",
                    value = string.format("%.2f, %.2f, %.2f",
                        normalizedCoords.x,
                        normalizedCoords.y,
                        normalizedCoords.z
                    ),
                    inline = false
                }
            }
        })
    end
end)

-- ==============================
-- Explosion Event
-- ==============================

-- Explosion Type Lookup
local explosionTypes = {
    [0] = "Grenade",
    [1] = "Grenade Launcher",
    [2] = "Sticky Bomb",
    [3] = "Molotov",
    [4] = "Rocket",
    [5] = "Tank Shell",
    [6] = "Hi Octane",
    [7] = "Car Explosion",
    [8] = "Plane",
    [9] = "Petrol Pump Explosion",
    [10] = "Bike Explosion",
    [11] = "DirGas",
    [12] = "Boat Explosion",
    [13] = "ShipDestroy",   -- Hitting a Fire Hydrant will trigger this explosionType
    [14] = "Truck Explosion",
    [15] = "Bullet",
    [16] = "SmokeGrenade",
    [17] = "BZGas",
    [18] = "Flare",
    [19] = "Gas Canister",
    [20] = "Extinguisher",
    [21] = "Portable Water",
    [22] = "FireWork Explosion",
    [23] = "Snowball"
}

local function getExplosionName(typeId)
    return explosionTypes[typeId] or ("Unknown (" .. tostring(typeId) .. ")")
end

-- List of explosion type IDs to ignore
local ignoredExplosionTypes = {
    [13] = "ShipDestroy",   -- Hitting a Fire Hydrant will trigger this explosionType
    [23] = "Snowball"
}

AddEventHandler('explosionEvent', function(sender, ev)
    if not Config.LogExplosions then return end

    -- Skip ignored explosion types
    if ignoredExplosionTypes[ev.explosionType] then
        return
    end

    DebugPrint('[SERVER] Explosion event:', 'type=' .. tostring(ev.explosionType), 
        'damageScale=' .. tostring(ev.damageScale), 
        'coords=(' .. ev.posX .. ',' .. ev.posY .. ',' .. ev.posZ .. ')'
    )

    -- NDJSON Logging
    WriteLog(baseLog('explosion', {
        explosionType = ev.explosionType,
        coords = { x = ev.posX, y = ev.posY, z = ev.posZ } -- explosionEvent coordinates are not always reliable for vehicle explosions. Grenades/missiles are fine; car explosions can give bogus coords.
    }))
    
    -- Discord Logging
    if Config.DiscordLogs and Config.DiscordLogs.explosion then

        LogToDiscord('explosion', nil, {
            title = "Explosion Event",
            color = 15158332, -- red
            fields = {
                {
                    name = "Explosion Type",
                    value = getExplosionName(ev.explosionType),
                    inline = true
                },
                {
                    name = "Coords", -- explosionEvent coordinates are not always reliable for vehicle explosions. Grenades/missiles are fine; car explosions can give bogus coords.
                    value = string.format("%.2f, %.2f, %.2f", ev.posX, ev.posY, ev.posZ),
                    inline = false
                }
            }
        })
    end
end)

-- ==============================
-- Chat Logs
-- ==============================
local function BuildChatLogTemplate(src, command, rawMessage)
    local playerName = GetPlayerName(src)
    local identifiers = GetSafeIdentifiers(src)

    return {
        type = ('chat_%s'):format(command),
        timestamp = os.time(),
        data = {
            player = {
                id = src,
                name = playerName,
                identifiers = identifiers
            },
            message = rawMessage
        }
    }
end

-- Command Hook Logger
local function LogChatCommand(src, command, rawMessage)
    -- Build the base log entry
    local entry = BuildChatLogTemplate(src, command, rawMessage)

    -- Attach base Loki labels from config
    entry.labels = entry.labels or {}
    for k, v in pairs(Config.LokiLabels) do
        entry.labels[k] = v
    end

    -- Add dynamic labels for filtering
    entry.labels.chat_command = command       -- log which command was used
    entry.labels.player_id = tostring(src)    -- optional: filter by player

    -- NDJSON Logging
    WriteLog(entry)

    -- Discord Logging
    if Config.DiscordLogs and Config.DiscordLogs.chat then
        local playerName = GetPlayerName(src)
        local playerIdentifiers = GetSafeIdentifiers(src)

        LogToDiscord('chat', nil, {
            title = "Chat Command",
            color = 3447003, -- blue
            fields = {
                {
                    name = "Player",
                    value = string.format("%s (ID: %d)", playerName, src),
                    inline = true
                },
                {
                    name = "Identifiers",
                    value = (#playerIdentifiers > 0 and table.concat(playerIdentifiers, "\n") or "N/A"),
                    inline = false
                },
                {
                    name = "Command",
                    value = '/' .. command,
                    inline = true
                },
                {
                    name = "Message",
                    value = rawMessage,
                    inline = false
                }
            }
        })
    end
end

-- /me Hook
RegisterCommand('me', function(source, args, raw)
    if not Config.ChatLogs.enabled then return end
    if not Config.ChatLogs.commands.me then return end

    LogChatCommand(source, 'me', raw)
end, false)

-- /scene Hook
RegisterCommand('scene', function(source, args, raw)
    if not Config.ChatLogs.enabled then return end
    if not Config.ChatLogs.commands.scene then return end

    LogChatCommand(source, 'scene', raw)
end, false)

-- /ooc Hook
RegisterCommand('ooc', function(source, args, raw)
    if not Config.ChatLogs.enabled then return end
    if not Config.ChatLogs.commands.ooc then return end

    LogChatCommand(source, 'ooc', raw)
end, false)

-- ==============================
-- F8 Console Logging Logs
-- ==============================
RegisterNetEvent("ravn_logs:f8Command", function(cmd)
    if not Config.F8ConsoleLogs or not Config.F8ConsoleLogs.enabled then return end

    -- Normalize command name (Allows for F8 console entries to match config key if entered in upper or lowercase)
    cmd = string.lower(cmd)

    if Config.F8ConsoleLogs.commands then
        local allowed = Config.F8ConsoleLogs.commands[cmd]

        -- If config f8 commands set to false OR not defined, don't log
        if allowed ~= true then
            return
        end
    end

    local src = source
    local playerName = GetPlayerName(src)
    local playerIdentifiers = GetSafeIdentifiers(src)

    -- NDJSON Logging
    WriteLog(baseLog('f8_command_used', {
        event = "f8_command",
        player = playerName,
        id = src,
        identifiers = playerIdentifiers,
        command = cmd
    }))

        if Config.DiscordLogs
        and Config.DiscordLogs.f8commands
        and Config.F8ConsoleLogs
        and Config.F8ConsoleLogs.enabled
        and Config.F8ConsoleLogs.commands[cmd] then
        
        LogToDiscord('f8_console', nil, {
            title = "F8 Command Used",
            color = 3447003, -- blue
            fields = {
                {
                    name = "Player",
                    value = string.format("%s (ID: %d)", playerName, src),
                    inline = true
                },
                {
                    name = "Identifiers",
                    value = (#playerIdentifiers > 0 and table.concat(playerIdentifiers, "\n") or "N/A"),
                    inline = false
                },
                {
                    name = "F8 Command",
                    value = cmd,
                    inline = true
                }
            }
        })
    end
end)

-- ==============================
-- EXTENDED LOGGING MODULE
-- ==============================
-- Allows server owners to register additional custom logs
-- without modifying core logging logic.
-- 
-- Guidelines:
--   Use WriteLog() for NDJSON file logging
--   Use LogToDiscord() for Discord output
--
-- Architecture:
-- RegisterNetEvent -> Functions -> WriteLog/baseLog -> LogToDiscord
-- 
-- Add custom logging below this line.
-- ==========================================================