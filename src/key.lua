--[[
	🌹 Rose Theme Main Frame (Loader Edition - Status Fixed)
	Author: DeepSeek
	Description: Full-featured key verification UI with all premium effects.
	             On valid key, loads an external script from GitHub.
	             Hardcoded valid keys: "key1", "secret123", "premium2025".
	             Status label now updates for all cases.
	Window size: 440x400
]]

local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "RoseMainUI"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Services
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

-- ==================== CONFIGURATION ====================
local VALID_KEYS = {
	"key1",
	"secret123",
	"premium2025",
	-- Add more keys as needed
}

local EXTERNAL_SCRIPT_URL = "https://raw.githubusercontent.com/NexusHuby/Nexus/refs/heads/main/src/Main.Lua"

local cache_buster = "?v=" .. tostring(os.time())
local url_with_cache_buster = EXTERNAL_SCRIPT_URL .. cache_buster

local success, result = pcall(function()
    return game:HttpGet(url_with_cache_buster)
end)

-- ==================== THEME (ROSE) ====================
local Theme = {
	Name = "Rose",
	Accent = Color3.fromRGB(180, 55, 90),

	AcrylicMain = Color3.fromRGB(40, 40, 40),
	AcrylicBorder = Color3.fromRGB(130, 90, 110),
	AcrylicGradient = ColorSequence.new(Color3.fromRGB(190, 60, 135), Color3.fromRGB(165, 50, 70)),
	AcrylicNoise = 0.92,

	TitleBarLine = Color3.fromRGB(140, 85, 105),
	Tab = Color3.fromRGB(180, 140, 160),

	Element = Color3.fromRGB(200, 120, 170),
	ElementBorder = Color3.fromRGB(110, 70, 85),
	InElementBorder = Color3.fromRGB(120, 90, 90),
	ElementTransparency = 0.86,

	ToggleSlider = Color3.fromRGB(200, 120, 170),
	ToggleToggled = Color3.fromRGB(0, 0, 0),

	SliderRail = Color3.fromRGB(200, 120, 170),

	DropdownFrame = Color3.fromRGB(200, 160, 180),
	DropdownHolder = Color3.fromRGB(120, 50, 75),
	DropdownBorder = Color3.fromRGB(90, 40, 55),
	DropdownOption = Color3.fromRGB(200, 120, 170),

	Keybind = Color3.fromRGB(200, 120, 170),

	Input = Color3.fromRGB(200, 120, 170),
	InputFocused = Color3.fromRGB(20, 10, 30),
	InputIndicator = Color3.fromRGB(170, 150, 190),

	Dialog = Color3.fromRGB(120, 50, 75),
	DialogHolder = Color3.fromRGB(95, 40, 60),
	DialogHolderLine = Color3.fromRGB(90, 35, 55),
	DialogButton = Color3.fromRGB(120, 50, 75),
	DialogButtonBorder = Color3.fromRGB(155, 90, 115),
	DialogBorder = Color3.fromRGB(100, 70, 90),
	DialogInput = Color3.fromRGB(135, 55, 80),
	DialogInputLine = Color3.fromRGB(190, 160, 180),

	Text = Color3.fromRGB(240, 240, 240),
	SubText = Color3.fromRGB(170, 170, 170),
	Hover = Color3.fromRGB(200, 120, 170),
	HoverChange = 0.04,
}

-- Asset IDs for icons
local ASSETS = {
	Close = "rbxassetid://10709819059",      -- X icon
	Minimize = "rbxassetid://10723365086",   -- Minus icon
	Discord = "rbxassetid://10709799288",    -- Discord logo
	Key = "rbxassetid://10723364605",        -- Key icon
	Check = "rbxassetid://10709790644",      -- Checkmark icon
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
	local success, err = pcall(function()
		setclipboard(text)
	end)
	if not success then
		Notify({Title = "Copy Manually", Content = "📋 " .. text, Duration = 4})
	else
		Notify({Title = "Copied!", Content = "Text copied to clipboard.", Duration = 2})
	end
end

-- ==================== NOTIFICATION SYSTEM ====================
local NotificationHolder = Instance.new("Frame")
NotificationHolder.Name = "NotificationHolder"
NotificationHolder.Size = UDim2.new(0, 340, 1, -60)
NotificationHolder.Position = UDim2.new(1, -20, 1, -30)
NotificationHolder.AnchorPoint = Vector2.new(1, 1)
NotificationHolder.BackgroundTransparency = 1
NotificationHolder.Parent = gui

local NotificationList = Instance.new("UIListLayout")
NotificationList.HorizontalAlignment = Enum.HorizontalAlignment.Center
NotificationList.SortOrder = Enum.SortOrder.LayoutOrder
NotificationList.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotificationList.Padding = UDim.new(0, 12)
NotificationList.Parent = NotificationHolder

-- Function to create a notification
local function Notify(config)
	config.Title = config.Title or "Notification"
	config.Content = config.Content or ""
	config.SubContent = config.SubContent or ""
	config.Duration = config.Duration or 5

	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(1, 0, 0, 80)
	notif.BackgroundColor3 = Theme.AcrylicMain
	notif.BackgroundTransparency = 0.08
	notif.ClipsDescendants = true
	notif.Parent = NotificationHolder

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = notif

	local gradient = createGradient(Theme.AcrylicGradient, 135)
	gradient.Parent = notif

	local noise = Instance.new("ImageLabel")
	noise.Size = UDim2.new(1, 0, 1, 0)
	noise.BackgroundTransparency = 1
	noise.Image = "rbxassetid://1450216884"
	noise.ImageTransparency = Theme.AcrylicNoise
	noise.ScaleType = Enum.ScaleType.Tile
	noise.TileSize = UDim2.new(0, 64, 0, 64)
	noise.Parent = notif

	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.AcrylicBorder
	stroke.Parent = notif

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -40, 0, 20)
	title.Position = UDim2.new(0, 12, 0, 8)
	title.BackgroundTransparency = 1
	title.Text = config.Title
	title.TextColor3 = Theme.Text
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = notif

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 24, 0, 24)
	closeBtn.Position = UDim2.new(1, -28, 0, 6)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = ""
	closeBtn.Parent = notif

	local closeIcon = Instance.new("ImageLabel")
	closeIcon.Size = UDim2.new(0, 16, 0, 16)
	closeIcon.Position = UDim2.new(0.5, -8, 0.5, -8)
	closeIcon.BackgroundTransparency = 1
	closeIcon.Image = ASSETS.Close
	closeIcon.ImageColor3 = Theme.SubText
	closeIcon.Parent = closeBtn

	closeBtn.MouseEnter:Connect(function()
		tweenService:Create(closeIcon, TweenInfo.new(0.2), {ImageColor3 = Theme.Text}):Play()
	end)
	closeBtn.MouseLeave:Connect(function()
		tweenService:Create(closeIcon, TweenInfo.new(0.2), {ImageColor3 = Theme.SubText}):Play()
	end)

	local contentHolder = Instance.new("Frame")
	contentHolder.Size = UDim2.new(1, -24, 0, 0)
	contentHolder.Position = UDim2.new(0, 12, 0, 32)
	contentHolder.BackgroundTransparency = 1
	contentHolder.AutomaticSize = Enum.AutomaticSize.Y
	contentHolder.Parent = notif

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Padding = UDim.new(0, 4)
	listLayout.Parent = contentHolder

	local contentLabel = Instance.new("TextLabel")
	contentLabel.Size = UDim2.new(1, 0, 0, 14)
	contentLabel.BackgroundTransparency = 1
	contentLabel.Text = config.Content
	contentLabel.TextColor3 = Theme.Text
	contentLabel.Font = Enum.Font.Gotham
	contentLabel.TextSize = 14
	contentLabel.TextXAlignment = Enum.TextXAlignment.Left
	contentLabel.TextWrapped = true
	contentLabel.AutomaticSize = Enum.AutomaticSize.Y
	contentLabel.Parent = contentHolder

	local subContentLabel = Instance.new("TextLabel")
	subContentLabel.Size = UDim2.new(1, 0, 0, 14)
	subContentLabel.BackgroundTransparency = 1
	subContentLabel.Text = config.SubContent
	subContentLabel.TextColor3 = Theme.SubText
	subContentLabel.Font = Enum.Font.Gotham
	subContentLabel.TextSize = 13
	subContentLabel.TextXAlignment = Enum.TextXAlignment.Left
	subContentLabel.TextWrapped = true
	subContentLabel.AutomaticSize = Enum.AutomaticSize.Y
	subContentLabel.Visible = config.SubContent ~= ""
	subContentLabel.Parent = contentHolder

	task.wait()
	local contentHeight = contentHolder.AbsoluteSize.Y
	notif.Size = UDim2.new(1, 0, 0, 40 + contentHeight + 12)

	notif.Position = UDim2.new(1, 50, 0, 0)
	local slideTween = tweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
	slideTween:Play()

	local function close()
		if notif then
			local fadeTween = tweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 1})
			fadeTween:Play()
			fadeTween.Completed:Connect(function()
				if notif then notif:Destroy() end
			end)
		end
	end

	closeBtn.MouseButton1Click:Connect(close)

	if config.Duration then
		task.delay(config.Duration, close)
	end

	return {Close = close}
end

-- ==================== EXECUTOR DETECTION ====================
local function getExecutorName()
	local success, result = pcall(function()
		return getexecutorname()
	end)
	if success and type(result) == "string" and result ~= "" then
		return result
	end

	success, result = pcall(function()
		local name = identifyexecutor()
		if type(name) == "string" then
			return name
		elseif type(name) == "table" and name[1] then
			return name[1]
		end
	end)
	if success and result then
		return result
	end

	local commonVars = {
		"syn", "Krnl", "ScriptWare", "Electron", "OxygenU", "ProtoSmasher",
		"Fluxus", "SirHurt", "Comet", "VegaX"
	}
	for _, var in ipairs(commonVars) do
		if getfenv()[var] then
			return var
		end
	end

	return "Unknown"
end

local executorName = getExecutorName()

-- ==================== MAIN WINDOW ====================
local windowSize = UDim2.new(0, 440, 0, 400)
local windowPos = UDim2.new(0.5, -220, 0.5, -200)
local bgTransparency = 0.08

local mainFrame = roundedFrame(gui, windowSize, windowPos, Theme.AcrylicMain, Theme.AcrylicBorder, 12, bgTransparency)
mainFrame.ClipsDescendants = true
mainFrame.BackgroundTransparency = 1 -- Start transparent for opening animation

-- Store original size and animation flag for minimize
local originalSize = mainFrame.Size
local isAnimating = false
local isClosing = false

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

-- ==================== TITLE BAR ====================
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 42)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainFrame

local titleBarLine = Instance.new("Frame")
titleBarLine.Size = UDim2.new(1, 0, 0, 1)
titleBarLine.Position = UDim2.new(0, 0, 1, 0)
titleBarLine.BackgroundColor3 = Theme.TitleBarLine
titleBarLine.BorderSizePixel = 0
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
titleLabel.Text = "🔐 Key Authentication"
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

-- Title bar buttons with images
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

-- Close button with smooth fade-out only
local closeBtn = createTitleBarButton(ASSETS.Close, -4, function()
	if isClosing then return end
	isClosing = true
	-- Fade out only (no scale)
	local closeTween = tweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1
	})
	closeTween:Play()
	closeTween.Completed:Connect(function()
		gui:Destroy()
	end)
end)

-- Minimize button with faster animation
local minimized = false
local minBtn = createTitleBarButton(ASSETS.Minimize, -40, function()
	if isAnimating or isClosing then return end
	isAnimating = true
	minimized = not minimized
	
	if minimized then
		-- Collapse to title bar height (0.3s)
		local targetSize = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 42)
		local tween = tweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize})
		tween:Play()
		tween.Completed:Connect(function()
			isAnimating = false
		end)
	else
		-- Expand back (0.3s)
		local tween = tweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = originalSize})
		tween:Play()
		tween.Completed:Connect(function()
			isAnimating = false
		end)
	end
	
	Notify({Title = "Interface", Content = minimized and "Window minimized" or "Window restored", Duration = 2})
end)

-- Discord button (copy invite link)
local discordBtn = createTitleBarButton(ASSETS.Discord, -80, function()
	copyToClipboard("https://discord.gg/your-invite")
	Notify({Title = "Discord", Content = "Invite link copied!", Duration = 3})
end)

-- ==================== CONTENT AREA ====================
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -24, 1, -60)
content.Position = UDim2.new(0, 12, 0, 52)
content.BackgroundTransparency = 1
content.Parent = mainFrame

-- Instruction label
local instr = Instance.new("TextLabel")
instr.Size = UDim2.new(1, 0, 0, 20)
instr.Position = UDim2.new(0, 0, 0, 0)
instr.BackgroundTransparency = 1
instr.Text = "Enter your key"
instr.TextColor3 = Theme.SubText
instr.Font = Enum.Font.Gotham
instr.TextSize = 14
instr.TextXAlignment = Enum.TextXAlignment.Left
instr.Parent = content

-- Text input
local inputFrame = roundedFrame(content, UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 20), Theme.DialogInput, Theme.DialogButtonBorder, 6, 0)

local innerStroke = Instance.new("UIStroke")
innerStroke.Thickness = 1
innerStroke.Color = Theme.InElementBorder
innerStroke.Transparency = 0.5
innerStroke.Parent = inputFrame

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1, -12, 1, 0)
textBox.Position = UDim2.new(0, 8, 0, 0)
textBox.BackgroundTransparency = 1
textBox.PlaceholderText = "Enter your key"
textBox.PlaceholderColor3 = Theme.SubText
textBox.Text = ""
textBox.TextColor3 = Theme.Text
textBox.Font = Enum.Font.Gotham
textBox.TextSize = 14
textBox.ClearTextOnFocus = false
textBox.Parent = inputFrame

local indicator = Instance.new("Frame")
indicator.Size = UDim2.new(1, -4, 0, 1)
indicator.Position = UDim2.new(0, 2, 1, -1)
indicator.BackgroundColor3 = Theme.DialogInputLine
indicator.BorderSizePixel = 0
indicator.Parent = inputFrame

textBox.Focused:Connect(function()
	indicator.BackgroundColor3 = Theme.Accent
	indicator.Size = UDim2.new(1, -2, 0, 2)
	indicator.Position = UDim2.new(0, 1, 1, -2)
end)
textBox.FocusLost:Connect(function()
	indicator.BackgroundColor3 = Theme.DialogInputLine
	indicator.Size = UDim2.new(1, -4, 0, 1)
	indicator.Position = UDim2.new(0, 2, 1, -1)
end)

-- ==================== STATUS LABEL ====================
-- Moved BEFORE button click handlers so they can access it
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 24)
status.Position = UDim2.new(0, 0, 0, 135) -- Will be recalculated after buttons are placed, but fine
status.BackgroundTransparency = 1
status.Text = "🔹 Waiting for input..."
status.TextColor3 = Theme.SubText
status.Font = Enum.Font.Gotham
status.TextSize = 15
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = content

-- ==================== ACTION BUTTONS ====================
local buttonY = 90
local buttonWidth = 130
local buttonHeight = 36
local spacing = 10

local function createIconButton(text, iconAssetId, xPos, color, addGradient)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, buttonWidth, 0, buttonHeight)
	btn.Position = UDim2.new(0, xPos, 0, buttonY)
	btn.BackgroundColor3 = color or Theme.DialogButton
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.Parent = content

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	local stroke = Instance.new("UIStroke")
	stroke.Color = Theme.DialogButtonBorder
	stroke.Parent = btn

	local icon = Instance.new("ImageLabel")
	icon.Size = UDim2.new(0, 18, 0, 18)
	icon.Position = UDim2.new(0, 10, 0.5, -9)
	icon.BackgroundTransparency = 1
	icon.Image = iconAssetId
	icon.ImageColor3 = Theme.Text
	icon.Parent = btn

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -32, 1, 0)
	label.Position = UDim2.new(0, 32, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Theme.Text
	label.Font = Enum.Font.GothamBold
	label.TextSize = 15
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = btn

	if addGradient then
		local gradient = Instance.new("UIGradient")
		gradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 0.7)
		})
		gradient.Rotation = 90
		gradient.Parent = btn
	end

	local originalSize = btn.Size
	local originalColor = btn.BackgroundColor3
	local hoverTweenIn, hoverTweenOut, clickTween

	local function playHoverIn()
		if hoverTweenOut then hoverTweenOut:Cancel() end
		hoverTweenIn = tweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, buttonWidth * 1.05, 0, buttonHeight * 1.05),
			BackgroundColor3 = originalColor:Lerp(Color3.new(1, 1, 1), 0.15)
		})
		hoverTweenIn:Play()
	end

	local function playHoverOut()
		if hoverTweenIn then hoverTweenIn:Cancel() end
		hoverTweenOut = tweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = originalSize,
			BackgroundColor3 = originalColor
		})
		hoverTweenOut:Play()
	end

	local function playClick()
		if clickTween then clickTween:Cancel() end
		clickTween = tweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, buttonWidth * 0.95, 0, buttonHeight * 0.95),
			BackgroundColor3 = originalColor:Lerp(Color3.new(0, 0, 0), 0.1)
		})
		clickTween:Play()
		clickTween.Completed:Connect(function()
			local returnTween = tweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = originalSize,
				BackgroundColor3 = originalColor
			})
			returnTween:Play()
		end)
	end

	btn.MouseEnter:Connect(playHoverIn)
	btn.MouseLeave:Connect(playHoverOut)
	btn.MouseButton1Down:Connect(playClick)

	return btn
end

-- Get Key button
local getKeyBtn = createIconButton("Get Key", ASSETS.Key, 0, Theme.Accent, true)
getKeyBtn.MouseButton1Click:Connect(function()
	copyToClipboard("demo-key-123")
	Notify({Title = "Demo Key", Content = "demo-key-123", SubContent = "Copied to clipboard", Duration = 3})
	status.Text = "📋 Demo key copied!"
	status.TextColor3 = Theme.Accent
	print("Status updated to demo key copied") -- Debug
	task.delay(1.5, function()
		if status and status.Parent then
			status.Text = "🔹 Waiting for input..."
			status.TextColor3 = Theme.SubText
			print("Status reverted") -- Debug
		end
	end)
end)

-- Verify button – now loads external script on success
local verifyBtn = createIconButton("Verify", ASSETS.Check, buttonWidth + spacing, Theme.DialogButton, true)
verifyBtn.MouseButton1Click:Connect(function()
	local key = textBox.Text:gsub("%s+", "")
	print("Verify clicked, key = '" .. key .. "'") -- Debug
	if key == "" then
		status.Text = "❌ Please enter a key"
		status.TextColor3 = Color3.fromRGB(220, 80, 80)
		print("Status: empty key")
		task.delay(2, function()
			if status and status.Parent then
				status.Text = "🔹 Waiting for input..."
				status.TextColor3 = Theme.SubText
				print("Status reverted")
			end
		end)
		Notify({Title = "Error", Content = "Please enter a key.", Duration = 3})
		return
	end
	
	status.Text = "🔍 Checking key..."
	status.TextColor3 = Theme.Accent
	print("Status: checking")
	task.wait(0.5)
	
	local isValid = false
	for _, validKey in ipairs(VALID_KEYS) do
		if key == validKey then
			isValid = true
			break
		end
	end
	
	if isValid then
		status.Text = "✅ Loading main script..."
		status.TextColor3 = Color3.fromRGB(80, 200, 120)
		print("Status: loading script")
		Notify({Title = "Success", Content = "Key verified! Loading external script...", Duration = 2})
		
		-- Fetch and execute external script
		local success, result = pcall(function()
			return game:HttpGet(EXTERNAL_SCRIPT_URL)
		end)
		
		if success and result then
			local loadSuccess, loadErr = pcall(function()
				local func = loadstring(result)
				if func then func() else error("Failed to compile") end
			end)
			if loadSuccess then
				-- Close this GUI
				gui:Destroy()
			else
				status.Text = "❌ Load failed: " .. tostring(loadErr):sub(1, 30)
				status.TextColor3 = Color3.fromRGB(220, 80, 80)
				print("Status: load failed")
				Notify({Title = "Error", Content = "Failed to load script: " .. tostring(loadErr):sub(1, 50), Duration = 5})
			end
		else
			status.Text = "❌ Download failed"
			status.TextColor3 = Color3.fromRGB(220, 80, 80)
			print("Status: download failed")
			Notify({Title = "Error", Content = "Failed to download external script.", Duration = 4})
		end
	else
		status.Text = "❌ Invalid Key"
		status.TextColor3 = Color3.fromRGB(220, 80, 80)
		print("Status: invalid key")
		Notify({Title = "Invalid Key", Content = "The key you entered is not valid.", Duration = 3})
	end
end)

-- Update status position after buttons are placed (optional but good)
status.Position = UDim2.new(0, 0, 0, buttonY + buttonHeight + 15)

-- ==================== USERNAME WITH GLITCH EFFECT ====================
local usernameLabel = Instance.new("TextLabel")
usernameLabel.Size = UDim2.new(1, 0, 0, 22)
usernameLabel.Position = UDim2.new(0, 0, 0, buttonY + buttonHeight + 45)
usernameLabel.BackgroundTransparency = 1
usernameLabel.Text = "User: " .. player.Name
usernameLabel.TextColor3 = Theme.Accent
usernameLabel.Font = Enum.Font.Gotham
usernameLabel.TextSize = 14
usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
usernameLabel.Parent = content

-- Glitch effect
local originalName = player.Name
local glitchActive = false
task.spawn(function()
	while true do
		task.wait(1)
		if not glitchActive then
			glitchActive = true
			local randomStr = ""
			for i = 1, #originalName do
				randomStr = randomStr .. string.char(math.random(65, 90))
			end
			usernameLabel.Text = "User: " .. randomStr
			usernameLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
			task.wait(0.1)
			usernameLabel.Text = "User: " .. originalName
			usernameLabel.TextColor3 = Theme.Accent
			glitchActive = false
		end
	end
end)

-- ==================== EXECUTOR LABEL ====================
local executorLabel = Instance.new("TextLabel")
executorLabel.Size = UDim2.new(1, 0, 0, 22)
executorLabel.Position = UDim2.new(0, 0, 0, buttonY + buttonHeight + 72)
executorLabel.BackgroundTransparency = 1
executorLabel.Text = "Executor: " .. executorName
executorLabel.TextColor3 = Theme.SubText
executorLabel.Font = Enum.Font.Gotham
executorLabel.TextSize = 14
executorLabel.TextXAlignment = Enum.TextXAlignment.Left
executorLabel.Parent = content

-- ==================== DECORATIVE SPINNER ====================
local spinnerHolder = Instance.new("Frame")
spinnerHolder.Size = UDim2.new(0, 24, 0, 24)
spinnerHolder.Position = UDim2.new(1, -30, 0, buttonY + buttonHeight + 35)
spinnerHolder.BackgroundTransparency = 1
spinnerHolder.Parent = content

local spinner = Instance.new("ImageLabel")
spinner.Size = UDim2.new(1, 0, 1, 0)
spinner.BackgroundTransparency = 1
spinner.Image = "rbxassetid://6031094670"
spinner.ImageColor3 = Theme.Accent
spinner.Parent = spinnerHolder

local spinTween = tweenService:Create(spinner, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, true), {Rotation = 360})
spinTween:Play()

-- ==================== ORGANIC SWEEP LINE EFFECT ====================
local function createSweepLine()
	local line = Instance.new("Frame")
	line.Name = "SweepLine"
	line.Size = UDim2.new(1, 0, 0, 2)
	local startY = math.random() * 0.7
	line.Position = UDim2.new(0, 0, startY, 0)
	line.BackgroundColor3 = Theme.Accent
	line.BackgroundTransparency = 0.3 + math.random() * 0.3
	line.BorderSizePixel = 0
	line.ZIndex = 10
	line.Parent = mainFrame

	local duration = 1.5 + math.random() * 1.5
	local goal = {
		Position = UDim2.new(0, 0, 1, -2),
		BackgroundTransparency = 1
	}
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	local tween = tweenService:Create(line, tweenInfo, goal)
	tween:Play()

	local flickerTweens = {}
	local flickerSteps = math.random(3, 6)
	for i = 1, flickerSteps do
		task.wait(duration * i / flickerSteps * 0.5)
		if line and line.Parent then
			local flickerTrans = 0.2 + math.random() * 0.6
			local flickerTween = tweenService:Create(line, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {BackgroundTransparency = flickerTrans})
			table.insert(flickerTweens, flickerTween)
			flickerTween:Play()
		end
	end

	tween.Completed:Connect(function()
		for _, ft in ipairs(flickerTweens) do
			ft:Cancel()
		end
		if line then line:Destroy() end
	end)
end

-- Spawn lines at random intervals
task.spawn(function()
	while true do
		task.wait(math.random(2, 5))
		createSweepLine()
	end
end)

-- ==================== DRAGGABLE WINDOW ====================
local dragging = false
local dragInput, dragStart, startPos

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
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
local openTween = tweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
	Size = originalSize,
	BackgroundTransparency = bgTransparency
})
openTween:Play()

-- Welcome notification
task.wait(0.5)
Notify({Title = "Welcome", Content = "Key system loaded.", SubContent = "Rose theme", Duration = 4})

print("🌹 Rose Theme Main Frame (Loader Edition - Status Fixed) loaded successfully!")

[[-- local success, result = pcall(function()
    return game:HttpGet(EXTERNAL_SCRIPT_URL)
end)
if not success then
    warn("HTTP request failed:", result)
    return
end
local loadSuccess, loadErr = loadstring(result)
if not loadSuccess then
    warn("loadstring failed:", loadErr)
else
    loadSuccess()
end --]]
