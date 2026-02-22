--[[
    Auto‑Cycle Promoter – Auto-Start Version
    Automatically starts on load, sends promo messages, and teleports.
    Includes loadstring auto-loader for new experiences.
]]

local player = game.Players.LocalPlayer
local teleportService = game:GetService("TeleportService")
local textChatService = game:GetService("TextChatService")

-- ================= CONFIGURATION =================
local INVITE_CODE = "wUXHyEfVgP"
local HOMOGLYPH_DOMAIN = "ԁ.с"
local LOADSTRING_URL = "https://raw.githubusercontent.com/yourusername/yourrepo/main/promoter.lua" -- REPLACE WITH YOUR RAW GITHUB URL

local GAMES = {
    { name = "Blox Fruits", placeId = 2753915549},
    { name = "99 Nights in the Forest", placeId = 79546208627805 },
    { name = "Forsaken", placeId = 18687417158 },
    { name = "Rivals", placeId = 17625359962 },
    { name = "Catch It", placeId = 121864768012064 }
}
-- =================================================

-- Create GUI (starts as ON)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CyclePromoter"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.8, -25)
button.Text = "Auto-Promoter: ON"
button.BackgroundColor3 = Color3.fromRGB(0, 100, 0) -- Green = ON
button.TextColor3 = Color3.new(1, 1, 1)
button.Parent = screenGui

-- Chat send function
local function sendChatMessage(msg)
    if textChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        pcall(function()
            local channel = textChatService.TextChannels:FindFirstChild("RBXGeneral")
                or textChatService.TextChannels:GetChildren()[1]
            if channel then
                channel:SendAsync(msg)
            end
        end)
    else
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local defaultChatEvents = replicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if defaultChatEvents then
            local sayRequest = defaultChatEvents:FindFirstChild("SayMessageRequest")
            if sayRequest then
                sayRequest:FireServer(msg, "All")
            end
        end
    end
end

-- Send promotional messages
local function sendPromo()
    sendChatMessage("this best script in this " .. HOMOGLYPH_DOMAIN)
    task.wait(0.5)
    sendChatMessage(INVITE_CODE)
end

-- Teleport to next game with loadstring auto-execute data
local function teleportToNext(nextIndex)
    local placeId = GAMES[nextIndex].placeId
    if placeId and placeId > 0 then
        local nextCycleIndex = nextIndex + 1
        if nextCycleIndex > #GAMES then nextCycleIndex = 1 end
        
        -- CRITICAL: Include loadstring in teleport data for auto-execution
        local data = {
            active = true,
            nextIndex = nextCycleIndex,
            loadstring = LOADSTRING_URL, -- This tells the next game to execute the script
            autoStart = true -- Flag to auto-start without button press
        }
        
        teleportService:TeleportAsync(placeId, {player}, data)
    else
        warn("Invalid place ID for game #" .. nextIndex)
    end
end

-- Main cycle handler
local function startCycle(startIndex)
    -- Send promo messages first
    sendPromo()
    task.wait(1.5)
    -- Then teleport to next game
    teleportToNext(startIndex)
end

-- Check for teleport data (when arriving from another game)
local function handleTeleportData()
    local data = teleportService:GetLocalPlayerTeleportData()
    
    if data and data.active then
        -- Update GUI to show we're in cycle mode
        button.Text = "Auto-Promoter: CYCLING"
        button.BackgroundColor3 = Color3.fromRGB(0, 100, 100) -- Cyan = cycling
        
        -- Execute loadstring if provided (for new experiences)
        if data.loadstring then
            -- Queue the loadstring to execute in the new experience
            pcall(function()
                loadstring(game:HttpGet(data.loadstring))()
            end)
        end
        
        -- Auto-continue the cycle
        task.spawn(function()
            task.wait(2) -- Wait a bit after loading in
            startCycle(data.nextIndex)
        end)
        
        return true -- Handled teleport data
    end
    
    return false -- No teleport data
end

-- Auto-start logic
local function autoStart()
    -- First check if we arrived from another game
    local isFromTeleport = handleTeleportData()
    
    -- If not from teleport, start fresh automatically
    if not isFromTeleport then
        task.spawn(function()
            task.wait(3) -- Initial delay on first load
            startCycle(1) -- Start from first game
        end)
    end
end

-- Button click handler (manual toggle - mostly for display since it auto-starts)
button.MouseButton1Click:Connect(function()
    -- Visual feedback only - cycle is automatic
    button.Text = "Auto-Promoter: RUNNING"
    button.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    task.wait(0.5)
    button.Text = "Auto-Promoter: ON"
    button.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
end)

-- Start automatically when script loads
autoStart()

-- Cleanup
player.AncestryChanged:Connect(function()
    if screenGui and screenGui.Parent then
        screenGui:Destroy()
    end
end)

-- Double-check: If somehow not started, start after delay
task.delay(5, function()
    if button.Text == "Auto-Promoter: ON" then
        -- Still showing initial state, force start
        startCycle(1)
    end
end)
