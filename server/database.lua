local function databaseReady()
    return GetResourceState('oxmysql') == 'started'
end

local function tableName()
    local name = Config.Database.table
    return type(name) == 'string' and name:match('^[%w_]+$') and name or 'ravn_logs'
end

local function databaseCall(method, query, params, cb)
    if not databaseReady() then cb(nil, 'oxmysql is not started'); return end
    exports.oxmysql[method](query, params, cb)
end

CreateThread(function()
    if not Config.Sinks.database then return end
    for _ = 1, 120 do
        if databaseReady() then break end
        Wait(500)
    end
    local name = tableName()
    local sql = ([=[CREATE TABLE IF NOT EXISTS `%s` (
        `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
        `timestamp` BIGINT NOT NULL,
        `type` VARCHAR(64) NOT NULL,
        `player_id` VARCHAR(32) NULL,
        `player_name` VARCHAR(128) NULL,
        `data` LONGTEXT NOT NULL,
        `search_text` LONGTEXT NOT NULL,
        PRIMARY KEY (`id`),
        KEY `idx_time` (`timestamp`, `id`),
        KEY `idx_type` (`type`, `id`),
        KEY `idx_player` (`player_id`, `id`),
        FULLTEXT KEY `idx_search` (`search_text`),
        FULLTEXT KEY `idx_player_name_search` (`player_name`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]=]):format(name)
    databaseCall('query', sql, {}, function(result, err)
        if err or not result then print('^1[ravn-logs]^7 Database initialization failed: ' .. tostring(err or 'query failed'))
        else print('^2[ravn-logs]^7 Database history enabled') end
    end)
end)

function StoreDatabaseLog(entry, raw)
    local data = entry.data
    local player = data.player or data.victim or data.killer or data
    if type(player) ~= 'table' then player = {} end
    local playerId = (type(player.id) == 'string' or type(player.id) == 'number') and tostring(player.id):sub(1, 32) or nil
    local playerName = type(player.name) == 'string' and player.name:sub(1, 128) or nil
    local sql = ('INSERT INTO `%s` (`timestamp`, `type`, `player_id`, `player_name`, `data`, `search_text`) VALUES (?, ?, ?, ?, ?, ?)'):format(tableName())
    databaseCall('insert', sql, { entry.timestamp, entry.type, playerId, playerName, json.encode(data), raw }, function(result, err)
        if err or not result then print('^1[ravn-logs]^7 Database insert failed: ' .. tostring(err or 'query failed')) end
    end)
end

function QueryDatabaseLogs(filters, cb)
    if not databaseReady() then cb(nil, 'oxmysql is not started'); return end
    local dbTable = tableName()
    local where, params = {}, {}
    if filters.type then where[#where + 1] = '`type` = ?'; params[#params + 1] = filters.type end
    if filters.playerId then where[#where + 1] = '`player_id` = ?'; params[#params + 1] = filters.playerId end
    if filters.playerText then where[#where + 1] = 'MATCH(`player_name`) AGAINST (? IN BOOLEAN MODE)'; params[#params + 1] = filters.playerText end
    if filters.from then where[#where + 1] = '`timestamp` >= ?'; params[#params + 1] = filters.from end
    if filters.to then where[#where + 1] = '`timestamp` <= ?'; params[#params + 1] = filters.to end
    if filters.cursor then where[#where + 1] = '`id` < ?'; params[#params + 1] = filters.cursor end
    if filters.text then where[#where + 1] = 'MATCH(`search_text`) AGAINST (? IN BOOLEAN MODE)'; params[#params + 1] = filters.text end
    local sql = ('SELECT `id`, `timestamp`, `type`, `data` FROM `%s` %s ORDER BY `id` DESC LIMIT ?'):format(dbTable, #where > 0 and ('WHERE ' .. table.concat(where, ' AND ')) or '')
    local maxPage = math.min(50, math.max(1, tonumber(Config.Database.maxPageSize) or 50))
    local limit = math.min(maxPage, math.max(1, tonumber(filters.limit) or Config.Database.pageSize or 25))
    params[#params + 1] = limit + 1
    databaseCall('query', sql, params, function(rows, err)
        if err then cb(nil, tostring(err)); return end
        if type(rows) ~= 'table' then cb(nil, 'query failed'); return end
        local more = #rows > limit
        if more then rows[#rows] = nil end
        local result = {}
        for _, row in ipairs(rows) do
            local ok, data = pcall(json.decode, row.data)
            local encodedOk, encoded = pcall(json.encode, data)
            if not ok or not encodedOk or not encoded or #encoded > 16384 then
                data = { _viewerTruncated = true, message = 'Entry is too large to display in the viewer.' }
            end
            result[#result + 1] = { id = tonumber(row.id), timestamp = tonumber(row.timestamp), type = row.type, data = data or {} }
        end
        cb({ rows = result, cursor = more and tostring(result[#result].id) or nil }, nil)
    end)
end
