-- Ravn Logs (C) 2026 Ravn (Ravn-Dev)
-- Licensed under GNU GPLv3 (see LICENSE file)

local RESOURCE = GetCurrentResourceName()

-- Debug Helper
function DebugPrint(...)
    if Config.Debug then
        print('^5[ravn-logs DEBUG]^7', ...)
    end
end

-- Dictates to create one NDJSON file per calendar day
local function getLogFile()
    return string.format('logs/server-%s.ndjson', os.date('%Y%m%d'))
end

local LOG_FILE = getLogFile()

-- Ensure daily log file exists
CreateThread(function()
    -- Ensure directory exists by writing an empty file if needed
    if not LoadResourceFile(RESOURCE, LOG_FILE) then
        SaveResourceFile(RESOURCE, LOG_FILE, '', -1)
    end

    print(('^2[ravn-logs]^7 Logging to %s'):format(LOG_FILE))
end)

-- ==============================
-- Identifier Privacy Filter
-- ==============================
function GetSafeIdentifiers(src)
    local safe = {}

    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        if identifier:find("^discord:") then
            local discordId = identifier:match("discord:(%d+)")
            if discordId then
                table.insert(safe, "discord: <@" .. discordId .. ">")
            end
        
        elseif identifier:find("^license:")
        or identifier:find("^license2:")
        or identifier:find("^steam:")
        or identifier:find("^fivem:") then
            table.insert(safe, identifier)
        end
    end

    return safe
end

-- ==============================
-- Human-readable ISO timestamp
-- ==============================
local function toISO(timestamp)
    local t = os.date('!*t', timestamp) -- Set to UTC
            --os.date('*t', timestamp): This returns a table representing your Server's Local Time.
            --os.date('!*t', timestamp): This returns a table representing UTC (Greenwich Mean Time).
    return string.format('%04d-%02d-%02dT%02d:%02d:%02dZ',
        t.year, t.month, t.day,
        t.hour, t.min, t.sec
    )
end

-- ==============================
-- WriteLog Function
-- ==============================
---@param entry table
function WriteLog(entry)
    -- Attach Promtail / Loki labels safely (shallow copy)
    entry.labels = entry.labels or {}
    for k, v in pairs(Config.LokiLabels) do
        entry.labels[k] = v
    end

    -- Ensure timestamp is set
    local ts = entry.timestamp or os.time()

    -- Ensure timestamp is first
    local orderedEntry = {
        timestamp = ts,
        type = entry.type,
        labels = entry.labels,
        data = entry.data,
        iso = toISO(ts)
    }

    -- Check for daily rotation
    local currentFile = getLogFile()
    if currentFile ~= LOG_FILE then
        LOG_FILE = currentFile
        SaveResourceFile(RESOURCE, LOG_FILE, '', -1)
        DebugPrint('Rotated log file to', LOG_FILE)
    end
    -- Append entry as NDJSON
    local raw = LoadResourceFile(RESOURCE, LOG_FILE) or ''
    SaveResourceFile(RESOURCE, LOG_FILE, raw .. json.encode(orderedEntry) .. '\n', -1)
end

exports('WriteLog', WriteLog)

-- ==============================
-- Log Retention Cleanup
-- ==============================

CreateThread(function()
    Wait(5000) -- wait for server startup

    local resource = GetCurrentResourceName()
    local handle = io.popen('dir "' .. GetResourcePath(resource) .. '/logs" /b')
    if not handle then return end

    local now = os.time()

    for file in handle:lines() do
        local date = file:match('server%-(%d%d%d%d%d%d%d%d)%.ndjson')
        if date then
            local year = tonumber(date:sub(1,4))
            local month = tonumber(date:sub(5,6))
            local day = tonumber(date:sub(7,8))

            local fileTime = os.time({ year = year, month = month, day = day })
            local ageDays = os.difftime(now, fileTime) / 86400

            if ageDays > Config.LogRetentionDays then
                os.remove(GetResourcePath(resource) .. '/logs/' .. file)
                print(('^3[ravn-logs]^7 Deleted old log: %s'):format(file))
                DebugPrint('Deleted old log file:', file)
            end
        end
    end

    handle:close()
end)