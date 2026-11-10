local roleCache = {}
local requestTimes = {}

local function discordRole(src, cb)
    local discordId
    for _, id in ipairs(GetPlayerIdentifiers(src)) do discordId = id:match('^discord:(%d+)$') or discordId end
    local guild, role = Config.LogViewer.discordGuildId, Config.LogViewer.discordRoleId
    local token = GetConvar(Config.LogViewer.discordBotTokenConvar, '')
    if not discordId or type(guild) ~= 'string' or not guild:match('^%d+$')
        or type(role) ~= 'string' or not role:match('^%d+$') or token == '' then cb(false); return end
    local cached = roleCache[discordId]
    if cached and cached.expires > os.time() then cb(cached.allowed); return end
    PerformHttpRequest(('https://discord.com/api/v10/guilds/%s/members/%s'):format(guild, discordId), function(status, body)
        local ok, member = pcall(json.decode, body or '')
        local allowed = false
        if status == 200 and ok and type(member) == 'table' and type(member.roles) == 'table' then
            for _, memberRole in ipairs(member.roles) do if memberRole == role then allowed = true; break end end
        end
        roleCache[discordId] = { allowed = allowed, expires = os.time() + (allowed and 60 or 15) }
        cb(allowed)
    end, 'GET', '', { ['Authorization'] = 'Bot ' .. token, ['Content-Type'] = 'application/json' })
end

local function authorized(src, cb)
    local ace = IsPlayerAceAllowed(src, Config.LogViewer.acePermission)
    local mode = Config.LogViewer.accessMode
    if mode == 'ace' then cb(ace); return end
    if mode ~= 'discord' and mode ~= 'either' and mode ~= 'both' then cb(false); return end
    if mode == 'either' and ace then cb(true); return end
    discordRole(src, function(discord)
        if mode == 'discord' then cb(discord)
        elseif mode == 'both' then cb(ace and discord)
        else cb(ace or discord) end
    end)
end

local function rateAllowed(src, action, interval)
    local now = GetGameTimer()
    requestTimes[src] = requestTimes[src] or {}
    if requestTimes[src][action] and now >= requestTimes[src][action] and now - requestTimes[src][action] < interval then return false end
    requestTimes[src][action] = now
    return true
end

RegisterNetEvent('ravn_logs:viewerOpen', function()
    local src = source
    if not Config.LogViewer.enabled or not Config.Sinks.database or not rateAllowed(src, 'open', 1000) then return end
    authorized(src, function(ok)
        if GetPlayerName(src) then TriggerClientEvent('ravn_logs:viewerOpenResult', src, ok) end
    end)
end)

RegisterNetEvent('ravn_logs:viewerSearch', function(input)
    local src = source
    if type(input) ~= 'table' or not Config.LogViewer.enabled or not Config.Sinks.database then return end
    if not rateAllowed(src, 'search', 500) then
        TriggerClientEvent('ravn_logs:viewerSearchResult', src, nil, 'Please wait before searching again.')
        return
    end
    authorized(src, function(ok)
        if not GetPlayerName(src) then return end
        if not ok then TriggerClientEvent('ravn_logs:viewerSearchResult', src, nil, 'Access denied.'); return end
        local filters = { limit = math.min(50, math.max(1, tonumber(input.limit) or Config.Database.pageSize or 25)) }
        if type(input.type) == 'string' and #input.type <= 64 and input.type:match('^[%w_%-]+$') then filters.type = input.type end
        if type(input.player) == 'string' and input.player ~= '' then
            local player = input.player:sub(1, 64)
            if player:match('^%d+$') then
                filters.playerId = player
            else
                local words = {}
                for word in player:gmatch('[%w_]+') do if #word >= 3 then words[#words + 1] = '+' .. word .. '*' end end
                if #words == 0 then
                    TriggerClientEvent('ravn_logs:viewerSearchResult', src, nil, 'Enter a player ID or at least 3 letters of a name.')
                    return
                end
                filters.playerText = table.concat(words, ' ')
            end
        end
        for _, key in ipairs({ 'from', 'to', 'cursor' }) do
            local value = tonumber(input[key])
            if value and value >= 1 and value <= 9007199254740991 then filters[key] = math.floor(value) end
        end
        if type(input.text) == 'string' then
            local words = {}
            for word in input.text:sub(1, 160):gmatch('[%w_]+') do
                if #word >= 3 and #words < 8 then words[#words + 1] = '+' .. word .. '*' end
            end
            if #words > 0 then filters.text = table.concat(words, ' ') end
        end
        QueryDatabaseLogs(filters, function(result, err)
            if err then print('^1[ravn-logs]^7 Database search failed: ' .. err) end
            if GetPlayerName(src) then TriggerClientEvent('ravn_logs:viewerSearchResult', src, result, err and 'Log search failed.' or nil) end
        end)
    end)
end)

AddEventHandler('playerDropped', function() requestTimes[source] = nil end)
