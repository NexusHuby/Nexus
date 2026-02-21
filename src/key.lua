--[[
	🌹 Rose Theme Key Loader
	Author: DeepSeek
	Description: Minimal key input UI that loads the main frame from GitHub after verification.
	             Key = "key1". Replace the GitHub URL with your own raw link.
]]

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "KeyLoader"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Services
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")

-- ==================== THEME (ROSE) ====================
local Theme = {
	Name = "Rose",
	Accent = Color3.fromRGB(180, 55, 90),
	AcrylicMain = Color3.fromRGB(40, 40, 40),
	AcrylicBorder = Color3.fromRGB(130, 90, 110),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(190, 60, 135), Color3.fromRGB(165, 50, 70)),
	AcrylicNoise = 0.92,
	TitleBarLine = Color3.fromRGB(140, 85, 105),
	DialogInput = Color3.fromRGB(135, 55, 80),
	DialogButtonBorder = Color3.fromRGB(155, 90, 115),
	DialogButton = Color3.fromRGB(120, 50, 75),
	Text = Color3.fromRGB(240, 240, 240),
	SubText = Color3.fromRGB(170, 170, 170),
}

-- Asset IDs for icons
local ASSETS = {
	Close = "rbxassetid://7072725342",
	Minimize = "rbxassetid://5769388446",
	Discord = "rbxassetid://7743864734",
}

-- Helper: rounded frame with optional stroke
local function roundedFrame(parent, size, pos, color, strokeColor, cornerRadius, transparency)
	local frame = Instance.new("Frame")
	frame.Size = size
	frame.Position = pos
	frame.BackgroundColor3 = color
	frame.BackgroundTransparency = transparency or 0
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, cornerRadius or 8)
	corner.Parent = frame

	if strokeColor then
		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1
		stroke.Color = strokeColor
		stroke.Parent = frame
	end

	return frame
end

-- Helper: gradient
local function createGradient(colorSeq, rotation)
	local grad = Instance.new("UIGradient")
	grad.Color = colorSeq
	grad.Rotation = rotation or 90
	return grad
end

-- Safe clipboard function
local function copyToClipboard(text)
	local success = pcall(function() setclipboard(text) end)
	if not success then
		status.Text = "Copy manually: " .. text
		status.TextColor3 = Color3.fromRGB(255, 200, 100)
	else
		status.Text = "Copied!"
		status.TextColor3 = Color3.fromRGB(80, 200, 120)
		task.wait(1)
		status.Text = "Enter key"
		status.TextColor3 = Theme.SubText
	end
end

-- ==================== MAIN LOADER WINDOW ====================
local windowSize = UDim2.new(0, 300, 0, 200)
local windowPos = UDim2.new(0.5, -150, 0.5, -100)
local bgTransparency = 0.08

local mainFrame = roundedFrame(gui, windowSize, windowPos, Theme.AcrylicMain, Theme.AcrylicBorder, 12, bgTransparency)
mainFrame.ClipsDescendants = true
mainFrame.BackgroundTransparency = 1 -- for opening animation

local gradient = createGradient(Theme.AcrylicGradient, 135)
gradient.Parent = mainFrame

local noise = Instance.new("ImageLabel")
noise.Size = UDim2.new(1, 0, 1, 0)
noise.BackgroundTransparency = 1
noise.Image = "rbxassetid://1450216884"
noise.ImageTransparency = Theme.AcrylicNoise
noise.ScaleType = Enum.ScaleType.Tile
noise.TileSize = UDim2.new(0, 64, 0, 64)
noise.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 42)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainFrame

local titleBarLine = Instance.new("Frame")
titleBarLine.Size = UDim2.new(1, 0, 0, 1)
titleBarLine.Position = UDim2.new(0, 0, 1, 0)
titleBarLine.BackgroundColor3 = Theme.TitleBarLine
titleBarLine.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 150, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔑 Key Loader"
titleLabel.TextColor3 = Theme.Text
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Title bar buttons
local function createTitleBarButton(iconAssetId, posX, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 34, 1, -8)
	btn.Position = UDim2.new(1, posX, 0, 4)
	btn.AnchorPoint = Vector2.new(1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = titleBar

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7)
	corner.Parent = btn

	local icon = Instance.new("ImageLabel")
	icon.Size = UDim2.new(0, 16, 0, 16)
	icon.Position = UDim2.new(0.5, -8, 0.5, -8)
	icon.BackgroundTransparency = 1
	icon.Image = iconAssetId
	icon.ImageColor3 = Theme.Text
	icon.Parent = btn

	local function setHover(trans)
		tweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = trans}):Play()
	end

	btn.MouseEnter:Connect(function() setHover(0.94) end)
	btn.MouseLeave:Connect(function() setHover(1) end)
	btn.MouseButton1Down:Connect(function() setHover(0.96) end)
	btn.MouseButton1Up:Connect(function() setHover(0.94) end)
	btn.MouseButton1Click:Connect(callback)

	return btn
end

local closeBtn = createTitleBarButton(ASSETS.Close, -4, function() gui:Destroy() end)
local minBtn = createTitleBarButton(ASSETS.Minimize, -40, function()
	mainFrame.Visible = not mainFrame.Visible
end)
local discordBtn = createTitleBarButton(ASSETS.Discord, -80, function()
	copyToClipboard("https://discord.gg/your-invite")
end)

-- Content area
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -24, 1, -60)
content.Position = UDim2.new(0, 12, 0, 50)
content.BackgroundTransparency = 1
content.Parent = mainFrame

-- Instruction
local instr = Instance.new("TextLabel")
instr.Size = UDim2.new(1, 0, 0, 20)
instr.Position = UDim2.new(0, 0, 0, 0)
instr.BackgroundTransparency = 1
instr.Text = "Enter key to load main UI"
instr.TextColor3 = Theme.SubText
instr.Font = Enum.Font.Gotham
instr.TextSize = 14
instr.TextXAlignment = Enum.TextXAlignment.Left
instr.Parent = content

-- Input field
local inputFrame = roundedFrame(content, UDim2.new(1, 0, 0, 36), UDim2.new(0, 0, 0, 25), Theme.DialogInput, Theme.DialogButtonBorder, 6, 0)
local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -12, 1, 0)
textBox.Position = UDim2.new(0, 8, 0, 0)
textBox.BackgroundTransparency = 1
textBox.PlaceholderText = "key1"
textBox.PlaceholderColor3 = Theme.SubText
textBox.Text = ""
textBox.TextColor3 = Theme.Text
textBox.Font = Enum.Font.Gotham
textBox.TextSize = 14
textBox.ClearTextOnFocus = false
textBox.Parent = inputFrame

-- Verify button
local verifyBtn = Instance.new("TextButton")
verifyBtn.Size = UDim2.new(1, 0, 0, 36)
verifyBtn.Position = UDim2.new(0, 0, 0, 70)
verifyBtn.BackgroundColor3 = Theme.Accent
verifyBtn.Text = "Verify"
verifyBtn.TextColor3 = Theme.Text
verifyBtn.Font = Enum.Font.GothamBold
verifyBtn.TextSize = 16
verifyBtn.AutoButtonColor = false
verifyBtn.Parent = content

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = verifyBtn

-- Hover/click effects for verify button
verifyBtn.MouseEnter:Connect(function()
	tweenService:Create(verifyBtn, TweenInfo.new(0.2), {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundColor3 = Theme.Accent:Lerp(Color3.new(1,1,1), 0.1)
	}):Play()
end)
verifyBtn.MouseLeave:Connect(function()
	tweenService:Create(verifyBtn, TweenInfo.new(0.2), {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = Theme.Accent
	}):Play()
end)
verifyBtn.MouseButton1Down:Connect(function()
	tweenService:Create(verifyBtn, TweenInfo.new(0.1), {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = Theme.Accent:Lerp(Color3.new(0,0,0), 0.1)
	}):Play()
end)
verifyBtn.MouseButton1Up:Connect(function()
	tweenService:Create(verifyBtn, TweenInfo.new(0.1), {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundColor3 = Theme.Accent
	}):Play()
end)

-- Status label
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 20)
status.Position = UDim2.new(0, 0, 0, 115)
status.BackgroundTransparency = 1
status.Text = "Waiting..."
status.TextColor3 = Theme.SubText
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = content

-- Dragging
local dragging = false
local dragStart, startPos
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then dragging = false end
		end)
	end
end)
titleBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)
userInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Opening animation
mainFrame.Size = UDim2.new(0, 0, 0, 0)
task.wait()
local openTween = tweenService:Create(mainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
	Size = windowSize,
	BackgroundTransparency = bgTransparency
})
openTween:Play()

-- Verification logic
local GITHUB_RAW_URL = "https://raw.githubusercontent.com/yourusername/yourrepo/main/mainframe.lua" -- REPLACE THIS

verifyBtn.MouseButton1Click:Connect(function()
	local key = textBox.Text:gsub("%s+", "")
	if key == "" then
		status.Text = "Please enter a key"
		status.TextColor3 = Color3.fromRGB(220,80,80)
		return
	end
	
	status.Text = "🔍 Checking..."
	status.TextColor3 = Theme.Accent
	task.wait(1)
	
	if key == "key1" then
		status.Text = "✅ Loading main UI..."
		status.TextColor3 = Color3.fromRGB(80,200,120)
		
		-- Fetch and load main frame from GitHub
		local success, result = pcall(function()
			return game:HttpGet(GITHUB_RAW_URL)
		end)
		
		if success and result then
			local loadSuccess, loadErr = pcall(function()
				local func = loadstring(result)
				if func then func() else error("Failed to compile") end
			end)
			if loadSuccess then
				-- Optionally close loader
				task.wait(0.5)
				gui:Destroy()
			else
				status.Text = "❌ Load failed: " .. tostring(loadErr):sub(1,30)
				status.TextColor3 = Color3.fromRGB(220,80,80)
			end
		else
			status.Text = "❌ Download failed"
			status.TextColor3 = Color3.fromRGB(220,80,80)
		end
	else
		status.Text = "❌ Invalid key"
		status.TextColor3 = Color3.fromRGB(220,80,80)
	end
end)

print("🌹 Key Loader ready. Replace the GitHub URL with your own.")
