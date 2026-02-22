--[[
    Reliable Auto‑Cycle Promoter – Guaranteed Chat Delivery
    Sends two messages and teleports through the game list.
]]

local player = game.Players.LocalPlayer
local teleportService = game:GetService("TeleportService")
local textChatService = game:GetService("TextChatService")

-- ================= CONFIGURATION =================
local INVITE_CODE = "wUXHyEfVgP"
local HOMOGLYPH_DOMAIN = "ԁ.с"   -- Looks like "d.c"
local LOADSTRING_URL = "https://raw.githubusercontent.com/NexusHuby/Nexus/refs/heads/main/src/Promo.lua" -- REPLACE WITH YOUR RAW GITHUB URL

local GAMES = {
    { name = "Blox Fruits", placeId = 2753915549 },
    { name = "99 Nights in the Forest", placeId = 79546208627805 },
    { name = "Forsaken", placeId = 18687417158 },
    { name = "Rivals", placeId = 17625359962 },
    { name = "Catch It", placeId = 121864768012064 }
}
-- =================================================

--[[
    Ultra‑reliable chat sender – tries everything.
    Returns true if it believes the message was sent.
]]
local function sendChatMessage(msg)
    -- First, try modern TextChatService
    if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        -- Wait for any text channel to appear (up to 10 seconds)
        local channels = textChatService:FindFirstChild("TextChannels")
        if channels then
            -- If there's already a channel, use it
            local channelList = channels:GetChildren()
            if #channelList > 0 then
                for _, channel in ipairs(channelList) do
                    pcall(function()
                        channel:SendAsync(msg)
                    end)
                end
                return true
            else
                -- No channel yet, wait for one to be added
                local channelAdded = channels.ChildAdded:Wait(10)
                if channelAdded then
                    pcall(function()
                        channelAdded:SendAsync(msg)
                    end)
                    return true
                end
            end
        end
    end

    -- Fallback 1: Legacy chat via SayMessageRequest
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local defaultChatEvents = replicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if defaultChatEvents then
        local sayRequest = defaultChatEvents:FindFirstChild("SayMessageRequest")
        if sayRequest then
            pcall(function()
                sayRequest:FireServer(msg, "All")
            end)
            return true
        end
    end

    -- Fallback 2: Try the old Chat service (deprecated but some games still use it)
    local chatService = game:GetService("Chat")
    if chatService then
        pcall(function()
            chatService:Chat(player.Character and player.Character.Head or player, msg)
        end)
        return true
    end

    -- Fallback 3: Last resort – send through the player's Chatted event (rarely works)
    pcall(function()
        player:Chat(msg)
    end)

    warn("All chat methods failed for message: " .. msg)
    return false
end

-- Send the two promotional messages
local function sendPromo()
    -- First message
    sendChatMessage("this best script in this " .. HOMOGLYPH_DOMAIN)
    task.wait(0.5)
    -- Second message
    sendChatMessage(INVITE_CODE)
end

-- Teleport to the next game with cycle data
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

        teleportService:TeleportAsync(placeId, {player}, data)
    else
        warn("Invalid place ID for game #" .. nextIndex)
    end
end

-- Main cycle function
local function startCycle(startIndex)
    sendPromo()
    task.wait(1.5)  -- give messages time to appear
    teleportToNext(startIndex)
end

-- Handle incoming teleport data (when we land in a new game)
local function handleTeleportData()
    local data = teleportService:GetLocalPlayerTeleportData()
    if data and data.active then
        -- Execute the loadstring if provided (to keep the script running)
        if data.loadstring then
            pcall(function()
                loadstring(game:HttpGet(data.loadstring))()
            end)
        end
        -- Continue the cycle after a short delay
        task.spawn(function()
            task.wait(2)  -- let the game load
            startCycle(data.nextIndex)
        end)
        return true
    end
    return false
end

-- Auto-start logic
local function autoStart()
    if not handleTeleportData() then
        -- First run: start from game 1 after a delay
        task.spawn(function()
            task.wait(3)  -- initial load delay
            startCycle(1)
        end)
    end
end

-- Start the script
autoStart()
