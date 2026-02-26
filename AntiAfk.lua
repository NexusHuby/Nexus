-- Anti-AFK Script for Roblox
-- Prevents being kicked for inactivity by simulating random movements

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Configuration
local CONFIG = {
    MoveInterval = 15, -- Move every 15 seconds (adjust based on game's kick timer)
    JumpInterval = 45, -- Jump every 45 seconds
    RandomOffset = 5,  -- Random variance to appear human-like
    WalkDistance = 5,  -- How far to walk
    Enabled = true
}

-- State tracking
local lastMove = 0
local lastJump = 0
local isMoving = false

-- Random number helper
local function randomRange(min, max)
    return math.random() * (max - min) + min
end

-- Get random movement direction
local function getRandomDirection()
    local directions = {
        Vector3.new(1, 0, 0),   -- Right
        Vector3.new(-1, 0, 0),  -- Left
        Vector3.new(0, 0, 1),   -- Forward
        Vector3.new(0, 0, -1),  -- Backward
        Vector3.new(0.7, 0, 0.7),   -- Diagonal
        Vector3.new(-0.7, 0, -0.7), -- Diagonal
    }
    return directions[math.random(1, #directions)]
end

-- Simulate movement
local function simulateMovement()
    if not CONFIG.Enabled or not humanoid or humanoid.Health <= 0 then return end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    
    -- Don't interrupt if already moving significantly
    if rootPart.Velocity.Magnitude > 2 then
        lastMove = tick()
        return
    end
    
    isMoving = true
    
    -- Small rotation to appear natural
    local currentRot = rootPart.CFrame
    local newRot = currentRot * CFrame.Angles(0, math.rad(randomRange(-30, 30)), 0)
    
    -- Walk in random direction briefly
    local direction = getRandomDirection()
    humanoid:Move(direction, true)
    
    -- Stop after short duration
    task.delay(randomRange(0.3, 0.8), function()
        humanoid:Move(Vector3.zero, true)
        isMoving = false
        lastMove = tick()
    end)
end

-- Simulate jump
local function simulateJump()
    if not CONFIG.Enabled or not humanoid or humanoid.Health <= 0 then return end
    
    if humanoid.FloorMaterial ~= Enum.Material.Air then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        lastJump = tick()
    end
end

-- Camera micro-movement (some games track camera)
local function simulateCamera()
    local camera = workspace.CurrentCamera
    if camera then
        local currentCFrame = camera.CFrame
        local offset = CFrame.Angles(
            math.rad(randomRange(-2, 2)), 
            math.rad(randomRange(-2, 2)), 
            0
        )
        camera.CFrame = currentCFrame * offset
    end
end

-- Main loop
local connection
connection = RunService.Heartbeat:Connect(function()
    if not CONFIG.Enabled then return end
    
    local currentTime = tick()
    
    -- Check if character respawned
    if not character or not character.Parent then
        character = player.Character
        if character then
            humanoid = character:WaitForChild("Humanoid")
        end
        return
    end
    
    -- Random movement
    if currentTime - lastMove > (CONFIG.MoveInterval + randomRange(-CONFIG.RandomOffset, CONFIG.RandomOffset)) then
        simulateMovement()
        simulateCamera()
    end
    
    -- Occasional jump
    if currentTime - lastJump > (CONFIG.JumpInterval + randomRange(-10, 10)) then
        simulateJump()
    end
end)

-- Handle respawn
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    lastMove = tick()
    lastJump = tick()
end)

-- UI Notification
local function notify(msg)
    if game:GetService("StarterGui") then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Anti-AFK",
            Text = msg,
            Duration = 3
        })
    end
end

notify("Anti-AFK Enabled! Moving every ~15s")

-- Toggle command (type in chat)
player.Chatted:Connect(function(msg)
    if msg:lower() == "/afkoff" then
        CONFIG.Enabled = false
        notify("Anti-AFK Disabled")
    elseif msg:lower() == "/afkon" then
        CONFIG.Enabled = true
        lastMove = tick()
        notify("Anti-AFK Enabled")
    end
end)

print("Anti-AFK Script Loaded!")
print("Commands: /afkoff - Disable | /afkon - Enable")
