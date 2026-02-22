--[[
	🌹 Rose Theme External Frame (Fixed Background)
	Author: DeepSeek
	Description: Uses identical background styling as the working key frame.
	             Features: draggable, resizable, tabs, sidebar.
]]

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "RoseExternalUI"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Services
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")

-- ==================== THEME (ROSE) - EXACTLY AS WORKING KEY FRAME ====================
local Theme = {
	Name = "Rose",
	Accent = Color3.fromRGB(180, 55, 90),

	AcrylicMain = Color3.fromRGB(40, 40, 40),
	AcrylicBorder = Color3.fromRGB(130, 90, 110),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(190, 60, 135), Color3.fromRGB(165, 50, 70)),
	AcrylicNoise = 0.92,

	TitleBarLine = Color3.fromRGB(140, 85, 105),
	Tab = Color3.fromRGB(180, 140, 160),
	ElementBorder = Color3.fromRGB(110, 70, 85),

	Text = Color3.fromRGB(240, 240, 240),
	SubText = Color3.fromRGB(170, 170, 170),
}

-- Asset IDs for icons
local ASSETS = {
	Close = "rbxassetid://7072725342",
	Minimize = "rbxassetid://5769388446",
	Discord = "rbxassetid://7743864734",
	Home = "rbxassetid://5769384002",      -- Key icon for home
	Settings = "rbxassetid://6034509580",   -- Gear icon
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
		print("Copy manually: " .. text)
	else
		print("Copied to clipboard!")
	end
end

-- ==================== MAIN WINDOW ====================
local windowSize = UDim2.new(0, 650, 0, 450)
local windowPos = UDim2.new(0.5, -325, 0.5, -225)
local bgTransparency = 0.08  -- SAME as working key frame

local mainFrame = roundedFrame(gui, windowSize, windowPos, Theme.AcrylicMain, Theme.AcrylicBorder, 12, bgTransparency)
mainFrame.ClipsDescendants = true
mainFrame.BackgroundTransparency = 1  -- for opening animation

local originalSize = mainFrame.Size
local isAnimating = false
local isClosing = false
local minimized = false

-- Gradient overlay (SAME as working key frame)
local gradient = createGradient(Theme.AcrylicGradient, 135)
gradient.Parent = mainFrame

-- Noise texture (SAME as working key frame)
local noise = Instance.new("ImageLabel")
noise.Size = UDim2.new(1, 0, 1, 0)
noise.BackgroundTransparency = 1
noise.Image = "rbxassetid://1450216884"
noise.ImageTransparency = Theme.AcrylicNoise
noise.ScaleType = Enum.ScaleType.Tile
noise.TileSize = UDim2.new(0, 64, 0, 64)
noise.Parent = mainFrame

-- ==================== TITLE BAR ====================
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 42)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainFrame

local titleBarLine = Instance.new("Frame")
titleBarLine.Size = UDim2.new(1, 0, 0, 1)
titleBarLine.Position = UDim2.new(0, 0, 1, 0)
titleBarLine.BackgroundColor3 = Theme.TitleBarLine
titleBarLine.Parent = titleBar

local leftContainer = Instance.new("Frame")
leftContainer.Size = UDim2.new(0, 200, 1, 0)
leftContainer.Position = UDim2.new(0, 16, 0, 0)
leftContainer.BackgroundTransparency = 1
leftContainer.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 0, 1, 0)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "✨ External UI"
titleLabel.TextColor3 = Theme.Text
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 14
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.AutomaticSize = Enum.AutomaticSize.X
titleLabel.Parent = leftContainer

local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(0, 0, 1, 0)
subtitleLabel.Position = UDim2.new(1, 5, 0, 0)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "Rose"
subtitleLabel.TextColor3 = Theme.SubText
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextSize = 12
subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
subtitleLabel.AutomaticSize = Enum.AutomaticSize.X
subtitleLabel.Parent = leftContainer

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

local closeBtn = createTitleBarButton(ASSETS.Close, -4, function()
	if isClosing then return end
	isClosing = true
	local closeTween = tweenService:Create(mainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1})
	closeTween:Play()
	closeTween.Completed:Connect(function() gui:Destroy() end)
end)

local minBtn = createTitleBarButton(ASSETS.Minimize, -40, function()
	if isAnimating or isClosing then return end
	isAnimating = true
	minimized = not minimized
	local targetSize = minimized and UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 42) or originalSize
	local tween = tweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = targetSize})
	tween:Play()
	tween.Completed:Connect(function() isAnimating = false end)
end)

local discordBtn = createTitleBarButton(ASSETS.Discord, -80, function()
	copyToClipboard("https://discord.gg/your-invite")
	print("Discord invite copied!")
end)

-- ==================== SIDEBAR & TABS ====================
local sidebarWidth = 150
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, sidebarWidth, 1, -60)
sidebar.Position = UDim2.new(0, 0, 0, 42)
sidebar.BackgroundTransparency = 1
sidebar.Parent = mainFrame

local divider = Instance.new("Frame")
divider.Size = UDim2.new(0, 1, 1, -60)
divider.Position = UDim2.new(0, sidebarWidth, 0, 42)
divider.BackgroundColor3 = Theme.ElementBorder
divider.Parent = mainFrame

local tabHolder = Instance.new("ScrollingFrame")
tabHolder.Size = UDim2.new(1, -10, 1, -10)
tabHolder.Position = UDim2.new(0, 5, 0, 5)
tabHolder.BackgroundTransparency = 1
tabHolder.ScrollBarThickness = 0
tabHolder.BorderSizePixel = 0
tabHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
tabHolder.Parent = sidebar

local tabList = Instance.new("UIListLayout")
tabList.Padding = UDim.new(0, 4)
tabList.Parent = tabHolder

local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -sidebarWidth - 2, 1, -60)
contentArea.Position = UDim2.new(0, sidebarWidth + 2, 0, 42)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

-- Tabs
local currentTab = nil

local function createTab(name, iconAssetId, contentBuilder)
	local tabButton = Instance.new("TextButton")
	tabButton.Size = UDim2.new(1, 0, 0, 34)
	tabButton.BackgroundTransparency = 1
	tabButton.Parent = tabHolder

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = tabButton

	local icon = Instance.new("ImageLabel")
	icon.Size = UDim2.new(0, 16, 0, 16)
	icon.Position = UDim2.new(0, 8, 0.5, -8)
	icon.BackgroundTransparency = 1
	icon.Image = iconAssetId
	icon.ImageColor3 = Theme.Text
	icon.Parent = tabButton

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -30, 1, 0)
	label.Position = UDim2.new(0, 30, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.TextColor3 = Theme.Text
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = tabButton

	-- Hover effects
	local hoverTween
	tabButton.MouseEnter:Connect(function()
		if hoverTween then hoverTween:Cancel() end
		hoverTween = tweenService:Create(tabButton, TweenInfo.new(0.15), {BackgroundTransparency = 0.94})
		hoverTween:Play()
	end)
	tabButton.MouseLeave:Connect(function()
		if hoverTween then hoverTween:Cancel() end
		hoverTween = tweenService:Create(tabButton, TweenInfo.new(0.15), {BackgroundTransparency = currentTab == tabButton and 0.89 or 1})
		hoverTween:Play()
	end)
	tabButton.MouseButton1Down:Connect(function()
		tweenService:Create(tabButton, TweenInfo.new(0.1), {BackgroundTransparency = 0.92}):Play()
	end)
	tabButton.MouseButton1Up:Connect(function()
		tweenService:Create(tabButton, TweenInfo.new(0.1), {BackgroundTransparency = currentTab == tabButton and 0.89 or 0.94}):Play()
	end)

	local contentFrame = Instance.new("Frame")
	contentFrame.Size = UDim2.new(1, -10, 1, -10)
	contentFrame.Position = UDim2.new(0, 5, 0, 5)
	contentFrame.BackgroundTransparency = 1
	contentFrame.Visible = false
	contentFrame.Parent = contentArea

	contentBuilder(contentFrame)

	tabButton.MouseButton1Click:Connect(function()
		if currentTab then
			currentTab.BackgroundTransparency = 1
			currentTab.Content.Visible = false
		end
		tabButton.BackgroundTransparency = 0.89
		contentFrame.Visible = true
		currentTab = tabButton
		currentTab.Content = contentFrame
	end)

	return tabButton, contentFrame
end

-- Tab content builders
local function buildHomeTab(parent)
	local welcomeLabel = Instance.new("TextLabel")
	welcomeLabel.Size = UDim2.new(1, 0, 1, 0)
	welcomeLabel.BackgroundTransparency = 1
	welcomeLabel.Text = "Welcome, " .. player.Name .. "!\nExternal script loaded successfully."
	welcomeLabel.TextColor3 = Theme.Text
	welcomeLabel.Font = Enum.Font.Gotham
	welcomeLabel.TextSize = 18
	welcomeLabel.TextWrapped = true
	welcomeLabel.Parent = parent
end

local function buildSettingsTab(parent)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = "Settings – under construction"
	label.TextColor3 = Theme.SubText
	label.Font = Enum.Font.Gotham
	label.TextSize = 16
	label.TextWrapped = true
	label.Parent = parent
end

-- Create tabs
local homeBtn, homeContent = createTab("Home", ASSETS.Home, buildHomeTab)
local settingsBtn, settingsContent = createTab("Settings", ASSETS.Settings, buildSettingsTab)

-- Select home tab
homeBtn.MouseButton1Click:Fire()

-- ==================== RESIZE HANDLE ====================
local resizeHandle = Instance.new("TextButton")
resizeHandle.Size = UDim2.new(0, 20, 0, 20)
resizeHandle.Position = UDim2.new(1, -20, 1, -20)
resizeHandle.BackgroundTransparency = 1
resizeHandle.Text = ""
resizeHandle.Parent = mainFrame

local resizing = false
local resizeStartPos, resizeStartSize

resizeHandle.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		resizing = true
		resizeStartPos = input.Position
		resizeStartSize = mainFrame.Size
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				resizing = false
			end
		end)
	end
end)

userInputService.InputChanged:Connect(function(input)
	if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - resizeStartPos
		local newWidth = math.max(400, resizeStartSize.X.Offset + delta.X)
		local newHeight = math.max(300, resizeStartSize.Y.Offset + delta.Y)
		mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
		originalSize = mainFrame.Size
	end
end)

-- ==================== DRAGGABLE WINDOW ====================
local dragging = false
local dragStart, startPos, dragInput

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

-- ==================== OPENING ANIMATION ====================
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.BackgroundTransparency = 1
task.wait()
local openTween = tweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
	Size = originalSize,
	BackgroundTransparency = bgTransparency  -- Use the same 0.08 as working frame
})
openTween:Play()

print("🌹 Rose External Frame (Background Fixed) loaded.")
