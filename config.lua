-- Ravn Logs (C) 2026 Ravn (Ravn-Dev)
-- Licensed under GNU GPLv3 (see LICENSE file)

Config = {}

-- ==============================
-- Debugging
-- ==============================
Config.Debug                = false     -- Debug logs for server/client console only (NDJSON file and Discord embeds are unaffected)

-- ==============================
-- Player Join and Disconnect Logs
-- ==============================
Config.LogPlayerJoin        = true      -- Logs when a player connects to the server
Config.LogPlayerDisconnect  = true      -- Logs when a player disconnects from the server

-- ==============================
-- Player Death Logs
-- ==============================
Config.LogDeaths            = true      -- Logs when players are killed by the environment
Config.LogVehicleDeaths     = true      -- Logs when a player is killed by a vehicle
Config.LogPvP               = true      -- Logs when a player is killed by another player
Config.LogSelfDeathVeh      = true      -- Logs when a player causes self inflicted death while in a vehicle
Config.LogSelfDeath         = true      -- Logs when a player causes self inflicted death

-- ==============================
-- Explosion Logs
-- ==============================
Config.LogExplosions        = true      -- Logs explosion events that occur in the GTA world

-- ==============================
-- Weapon Fire Logs
-- ==============================
Config.LogWeaponFires       = true      -- Logs when a player fires a weapon
Config.WeaponFireCooldownMs = 200       -- Sets cooldown in milliseconds between weapon fire logs

-- ==============================
-- Chat Logs
-- ==============================
Config.ChatLogs = {
    enabled = true,                     -- Allows for player chat messages to be logged

    commands = {
        me = true,                      -- Logs when a player sends a /me message in player chat
        scene = true,                   -- Logs when a player sends a /scene message in player chat
        ooc = true,                     -- Logs when a player sends a /ooc message in player chat
    }
}

-- ==============================
-- F8 Command Logs
-- ==============================
Config.F8ConsoleLogs = {
    enabled = true,                     -- Allows for F8 console messages to be logged. NOTE: Some FiveM console commands cannot be intercepted such as quit or disconnect.

    commands = {
        test = true,                    -- Logs when a player types Test in the F8 console, this can be changes if you have any custom commands you wish to log.
    }
}

-- ==============================
-- NDJSON Log File Retention
-- ==============================
-- NDJSON log files are located in ravn_logs/logs
Config.LogRetentionDays = 7  -- days logs are retained before cleanup


-- ==============================
-- Discord Embed Logs
-- ==============================
-- Add webhook URLs in: ravn_logs/server/discord.lua
Config.DiscordLogs = {
    player_join             = true,      -- Sends Discord Log for player joins (Config.LogPlayerJoin must be set to true)
    player_disconnect       = true,      -- Sends Discord Log for player disconnects (Config.LogPlayerDisconnect must be set to true)
    player_death            = true,      -- Sends Discord Log for player environmental deaths (Config.LogDeaths must be set to true)
    player_killed_vehicle   = true,      -- Sends Discord Log when a player is killed by a vehicle (Config.LogVehicleDeaths must be set to true)
    player_killed           = true,      -- Sends Discord Log when a player is killed by another player (Config.LogPvP must be set to true)
    self_inflicted_vehicle  = true,      -- Sends Discord Log when a player causes self inflicted death while in a vehicle (Config.LogSelfDeathVeh must be set to true)
    self_inflicted_death    = true,      -- Sends Discord Log when a player causes self inflicted death (Config.LogSelfDeath must be set to true)
    weapon_fired            = true,      -- Sends Discord Log when a player fires a weapon (Config.LogWeaponFires must be set to true)
    explosion               = true,      -- Sends Discord Log when an explosion event occurs in the GTA world (Config.LogExplosions must be set to true)
    chat                    = true,      -- Sends Discord Log when a player enters a chat command (Both Config.ChatLogs and the specific command needs to be set to true)
    f8commands              = true       -- Sends Discord Log when a player enters an F8 Console command (Both Config.F8ConsoleLogs and the specific command needs to be set to true)
}

-- ==============================
-- Labels for Loki / Promtail
-- ==============================
-- Static labels applied to every log entry
Config.LokiLabels = {
    job = 'fivem_server',                               -- example: server type/job
    instance = GetConvar('serverName', 'qbox_default')  -- example: server instance
    -- you can add more default labels here if needed
}