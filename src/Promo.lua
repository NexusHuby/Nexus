--[[
    Auto‑Cycle Promoter – Silent Automatic Version
    Sends messages and teleports through the game list. No GUI.
]]

local player = game.Players.LocalPlayer
local teleportService = game:GetService("TeleportService")
local textChatService = game:GetService("TextChatService")

-- ================= CONFIGURATION =================
local INVITE_CODE = "wUXHyEfVgP"
local HOMOGLYPH_DOMAIN = "ԁ.с"   -- Looks like "d.c"
local LOADSTRING_URL = "https://raw.githubusercontent.com/yourusername/yourrepo/main/promoter.lua" -- REPLACE WITH YOUR RAW GITHUB URL

local GAMES = {
    { name = "Blox Fruits", placeId = 2753915549 },
    { name = "99 Nights in the Forest", placeId = 79546208627805 },
    { name = "Forsaken", placeId = 18687417158 },
    { name = "Rivals", placeId = 17625359962 },
    { name = "Catch It", placeId = 121864768012064 }
}
-- =================================================

-- Robust chat sender – waits for chat to be ready and tries multiple methods
local function sendChatMessage(msg)
    -- Wait for chat to be available (max 10 seconds)
    local chatReady = false
    for i = 1, 20 do
        if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            if #textChatService.TextChannels:GetChildren() > 0 then
                chatReady = true
                break
            end
        else
            local replicatedStorage = game:GetService("ReplicatedStorage")
            local defaultChatEvents = replicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if defaultChatEvents and defaultChatEvents:FindFirstChild("SayMessageRequest") then
                chatReady = true
                break
            end
        end
        task.wait(0.5)
    end
    if not chatReady then
        warn("Chat system not ready after 10 seconds, aborting send.")
        return
    end

    -- Attempt to send using the appropriate method
    if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        -- Modern chat: try all channels
        local success = pcall(function()
            for _, channel in ipairs(textChatService.TextChannels:GetChildren()) do
                channel:SendAsync(msg)
                break -- Send only to first channel (usually RBXGeneral)
            end
        end)
        if not success then
            -- Fallback to legacy if modern fails (rare)
            local replicatedStorage = game:GetService("ReplicatedStorage")
            local defaultChatEvents = replicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
            if defaultChatEvents then
                local sayRequest = defaultChatEvents:FindFirstChild("SayMessageRequest")
                if sayRequest then
                    sayRequest:FireServer(msg, "All")
                end
            end
        end
    else
        -- Legacy chat
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local defaultChatEvents = replicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if defaultChatEvents then
            local sayRequest = defaultChatEvents:FindFirstChild("SayMessageRequest")
            if sayRequest then
                sayRequest:FireServer(msg, "All")
            else
                warn("SayMessageRequest not found in legacy chat.")
            end
        else
            warn("DefaultChatSystemChatEvents not found.")
        end
    end
end

-- Send the two promotional messages
local function sendPromo()
    sendChatMessage("this best script in this " .. HOMOGLYPH_DOMAIN)
    task.wait(0.5)  -- small delay so they appear in order
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
