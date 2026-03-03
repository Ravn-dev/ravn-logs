-- Ravn Logs (C) 2026 Ravn (Ravn-Dev)
-- Licensed under GNU GPLv3 (see LICENSE file)

local DISCORD_WEBHOOKS = {
    player_join = "SET DISCORD WEBHOOK URL HERE",
    player_disconnect = "SET DISCORD WEBHOOK URL HERE",
    player_death = "SET DISCORD WEBHOOK URL HERE",
    player_killed_vehicle = "SET DISCORD WEBHOOK URL HERE",
    player_killed = "SET DISCORD WEBHOOK URL HERE",
    self_inflicted_vehicle = "SET DISCORD WEBHOOK URL HERE",
    self_inflicted_death = "SET DISCORD WEBHOOK URL HERE",
    weapon_fired = "SET DISCORD WEBHOOK URL HERE",
    explosion = "SET DISCORD WEBHOOK URL HERE",
    chat = "SET DISCORD WEBHOOK URL HERE",
    f8_console = "SET DISCORD WEBHOOK URL HERE"
}

-- Track rate limits per webhook
local rateLimits = {
    -- If you have multiple Discord webhook URLs, add each webhook as its own line using the following template:
    --["https://discordwebhookurl.com"] = { remaining = number, resetAfter = number, global = boolean }
    ["SET DISCORD WEBHOOK URL HERE"] = { remaining = number, resetAfter = number, global = boolean }
}

local MAX_DISCORD_QUEUE = 1000 -- max logs to keep in memory
local MAX_DISCORD_RETRIES = 3 -- drop log after 3 failed attempts

local discordQueue = {}
local isProcessing = false

-- ==================================
-- Log To Discord
-- ==================================
function LogToDiscord(logType, username, message)
    local webhook = DISCORD_WEBHOOKS[logType]
    if not webhook then
        print("Unknown log type for Discord: " .. tostring(logType))
        return
    end

    if #discordQueue >= MAX_DISCORD_QUEUE then
        print("Discord queue full! Dropping log:", logType)
        return
    end

    table.insert(discordQueue, {
        webhook = webhook,
        username = username,
        message = message,
        retries = 0 -- Starts at zero
    })

    if not isProcessing then
        processDiscordQueue()
    end
end

-- ==================================
-- Safe Header Reader (Case-Insensitive)
-- ==================================
local function getHeader(headers, key)
    if not headers then return nil end

    for k, v in pairs(headers) do
        if string.lower(k) == string.lower(key) then
            return v
        end
    end

    return nil
end

-- ==================================
-- Queue Processor
-- ==================================
-- Retry a queue item with a delay and track retries
local function retryQueueItem(item, delay)
    item.retries = (item.retries or 0) + 1

    if item.retries > MAX_DISCORD_RETRIES then
        print("Dropping Discord log after max retries:", item.webhook)
        return -- drop the item
    end

    SetTimeout(delay, function()
        table.insert(discordQueue, 1, item)
        processDiscordQueue()
    end)
end

function processDiscordQueue()
    if #discordQueue == 0 then
        isProcessing = false
        return
    end

    isProcessing = true

    local item = table.remove(discordQueue, 1)

    local webhook = item.webhook
    local username = item.username
    local message = item.message

    local payload

    if type(message) == "table" then
        payload = {
            username = "ravn-logs",
            embeds = {
                {
                    title = message.title or "Log",
                    description = message.description,
                    color = message.color or 9807270,
                    fields = message.fields or {},
                    footer = { text = "ravn-logs" },
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                }
            }
        }
    else
        payload = {
            username = username or "Server Logs",
            content = message
        }
    end

    PerformHttpRequest(webhook, function(err, text, headers)

        -- ============================
        -- NETWORK ERROR HANDLING (Rate Limited)
        -- ============================
        if err == 429 then
            local retryAfter = 5000 -- default 5 seconds (ms)

            if text then
                local data = json.decode(text)
                if data and data.retry_after then
                    retryAfter = tonumber(data.retry_after) or 5000
                end
            end

            -- Set webhook-specific rate limit
            rateLimits[webhook] = {
                remaining = 0,
                resetAfter = retryAfter / 1000, -- convert ms > seconds
                global = getHeader(headers, "x-ratelimit-global") ~= nil
            }

            print("Discord 429 hit for webhook. Retrying in " .. retryAfter .. " ms for webhook " .. webhook)

            retryQueueItem(item, retryAfter)

            return
        end

        if err ~= 200 and err ~= 204 and err ~= 429 then
            print("Discord network error " .. tostring(err) .. ". Retrying in 5s for webhook " .. webhook)
            retryQueueItem(item, 5000)
            return
        end
            -- Err 200 - success
            -- Err 204 - success (Discord webhook - no content)
            -- Err 429 - rate limit
            -- Anything else > retry

        -- ============================
        -- READ RATE LIMIT HEADERS
        -- ============================
        if headers then
            local remaining = tonumber(getHeader(headers, "x-ratelimit-remaining"))
            local resetAfter = tonumber(getHeader(headers, "x-ratelimit-reset-after"))
            local global = getHeader(headers, "x-ratelimit-global") ~= nil

            rateLimits[webhook] = {
                remaining = remaining,
                resetAfter = resetAfter,
                global = global
            }

            -- Debug
            DebugPrint("[server/discord.lua]  Webhook rate limits:", webhook, remaining, resetAfter, global)
        end

        -- ============================
        -- DETERMINE NEXT DELAY
        -- ============================
        local rl = rateLimits[webhook]
        local nextDelay = 0

        if rl then
            if rl.global then
                local reset = rl.resetAfter or 5
                nextDelay = reset * 1000
                print("Global rate limit active. Waiting " .. nextDelay .. "ms for webhook " .. webhook)
            elseif rl.remaining and rl.remaining <= 0 then
                local reset = rl.resetAfter or 5
                nextDelay = reset * 1000
                print("Webhook bucket exhausted. Waiting " .. nextDelay .. "ms for webhook " .. webhook)
            else
                nextDelay = 250 -- small spacing to avoid burst spam
            end
        else
            nextDelay = 0
        end

        SetTimeout(nextDelay, function()
            processDiscordQueue()
        end)

    end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
end
