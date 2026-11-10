-- Ravn Logs (C) 2026 Ravn (Ravn-Dev), GPLv3
local RESOURCE = GetCurrentResourceName()

function DebugPrint(...)
    if Config.Debug then print('^5[ravn-logs DEBUG]^7', ...) end
end

function GetSafeIdentifiers(src)
    local safe = {}
    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        if identifier:match('^discord:%d+$') then
            safe[#safe + 1] = 'discord: <@' .. identifier:sub(9) .. '>'
        elseif identifier:match('^license:') or identifier:match('^license2:')
            or identifier:match('^steam:') or identifier:match('^fivem:') then
            safe[#safe + 1] = identifier
        end
    end
    return safe
end

local function logFile()
    return ('logs/server-%s.ndjson'):format(os.date('%Y%m%d'))
end

local function toISO(timestamp)
    return os.date('!%Y-%m-%dT%H:%M:%SZ', timestamp)
end

function WriteLog(entry)
    if type(entry) ~= 'table' or type(entry.type) ~= 'string' or #entry.type > 64 or type(entry.data) ~= 'table' then return false end
    local labels = {}
    for key, value in pairs(Config.LokiLabels or {}) do labels[key] = value end
    for key, value in pairs(type(entry.labels) == 'table' and entry.labels or {}) do
        if type(key) == 'string' and type(value) == 'string' then labels[key] = value end
    end

    local timestamp = tonumber(entry.timestamp) or os.time()
    if timestamp > 100000000000 then timestamp = math.floor(timestamp / 1000) end
    if timestamp ~= timestamp or timestamp < 0 or timestamp > 253402300799 then timestamp = os.time() end
    local ordered = { timestamp = timestamp, type = entry.type, labels = labels, data = entry.data, iso = toISO(timestamp) }
    local ok, raw = pcall(json.encode, ordered)
    if not ok or not raw or #raw > 65536 then return false end

    if Config.Sinks.ndjson then
        local file = io.open(GetResourcePath(RESOURCE) .. '/' .. logFile(), 'a')
        if not file then
            print('^1[ravn-logs]^7 Could not append NDJSON log')
        else
            local ok, result = pcall(function() return file:write(raw, '\n') end)
            file:close()
            if not ok or not result then print('^1[ravn-logs]^7 NDJSON write failed') end
        end
    end
    if Config.Sinks.database and StoreDatabaseLog then StoreDatabaseLog(ordered, raw) end
    return true
end

exports('WriteLog', WriteLog)

-- Server-side integration API: exports['ravn-logs']:SubmitLog('event_name', { ... })
exports('SubmitLog', function(eventType, data)
    if type(eventType) ~= 'string' or #eventType > 64 or not eventType:match('^[%w_%-]+$') or type(data) ~= 'table' then return false end
    return WriteLog({ type = eventType, data = data })
end)

CreateThread(function()
    Wait(5000)
    if Config.Sinks.ndjson then
        local file = io.open(GetResourcePath(RESOURCE) .. '/' .. logFile(), 'a')
        if file then file:close() end
        print(('^2[ravn-logs]^7 Logging to %s'):format(logFile()))
    end

    -- File names are date-derived, so cleanup needs no shell command or directory traversal.
    if not Config.Sinks.ndjson then return end
    local keep = math.max(0, math.floor(tonumber(Config.LogRetentionDays) or 7))
    local today = os.time({ year = tonumber(os.date('%Y')), month = tonumber(os.date('%m')), day = tonumber(os.date('%d')), hour = 12 })
    for age = keep + 1, keep + 3660 do
        local date = os.date('%Y%m%d', today - age * 86400)
        local path = GetResourcePath(RESOURCE) .. '/logs/server-' .. date .. '.ndjson'
        if os.remove(path) then DebugPrint('Deleted old log file:', date) end
    end
end)
