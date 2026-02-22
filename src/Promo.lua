--[[
    Reliable Auto‑Cycle Promoter – with error logging
]]
local player = game.Players.LocalPlayer
local teleportService = game:GetService("TeleportService")
local textChatService = game:GetService("TextChatService")

-- ================= CONFIGURATION =================
local INVITE_CODE = "wUXHyEfVgP"
local HOMOGLYPH_DOMAIN = "ԁ.с"
local LOADSTRING_URL = "https://raw.githubusercontent.com/NexusHuby/Nexus/refs/heads/main/src/Promo.lua" -- REPLACE WITH YOUR RAW GITHUB URL
local GAMES = {
    { name = "Blox Fruits", placeId = 2753915549 },
    { name = "99 Nights in the Forest", placeId = 79546208627805 },
    { name = "Forsaken", placeId = 18687417158 },
    { name = "Rivals", placeId = 17625359962 },
    { name = "Catch It", placeId = 121864768012064 }
}
-- =================================================

-- Reliable chat sender
local function sendChatMessage(msg)
    -- Modern chat
    if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        local channels = textChatService:FindFirstChild("TextChannels")
        if channels then
            local channelList = channels:GetChildren()
            if #channelList > 0 then
                for _, channel in ipairs(channelList) do
                    pcall(function() channel:SendAsync(msg) end)
                end
                return true
            else
                local channelAdded = channels.ChildAdded:Wait(5)
                if channelAdded then
                    pcall(function() channelAdded:SendAsync(msg) end)
                    return true
                end
            end
        end
    end

    -- Legacy chat
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local defaultChatEvents = replicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if defaultChatEvents then
        local sayRequest = defaultChatEvents:FindFirstChild("SayMessageRequest")
        if sayRequest then
            pcall(function() sayRequest:FireServer(msg, "All") end)
            return true
        end
    end

    warn("Failed to send message: " .. msg)
    return false
end

local function sendPromo()
    sendChatMessage("this best script in this " .. HOMOGLYPH_DOMAIN)
    task.wait(0.5)
    sendChatMessage(INVITE_CODE)
end

-- Teleport with error handling
local function teleportToNext(nextIndex)
    local placeId = GAMES[nextIndex].placeId
    if placeId and placeId > 0 then
        local nextCycleIndex = nextIndex + 1
        if nextCycleIndex > #GAMES then nextCycleIndex = 1 end

        local data = {
            active = true,
            nextIndex = nextCycleIndex,
            loadstring = LOADSTRING_URL,
            autoStart = true
        }

        local success, err = pcall(function()
            teleportService:TeleportAsync(placeId, {player}, data)
        end)
        if not success then
            warn("Teleport to " .. GAMES[nextIndex].name .. " failed: " .. tostring(err))
            -- Optionally retry or skip to next game
        end
    else
        warn("Invalid place ID for game #" .. nextIndex)
    end
end

local function startCycle(startIndex)
    sendPromo()
    task.wait(1.5)
    teleportToNext(startIndex)
end

-- Handle teleport data on arrival
local function handleTeleportData()
    local data = teleportService:GetLocalPlayerTeleportData()
    if data and data.active then
        if data.loadstring then
            pcall(function() loadstring(game:HttpGet(data.loadstring))() end)
        end
        task.spawn(function()
            task.wait(2)
            startCycle(data.nextIndex)
        end)
        return true
    end
    return false
end

-- Auto-start
local function autoStart()
    if not handleTeleportData() then
        task.spawn(function()
            task.wait(3)
            startCycle(1)
        end)
    end
end

autoStart()
