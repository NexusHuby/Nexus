local ScreenGui = Instance.new("ScreenGui")
local TextLabel = Instance.new("TextLabel")

local parent = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Parent = parent
ScreenGui.Name = "GameCheckUI"

TextLabel.Parent = ScreenGui
TextLabel.Size = UDim2.new(0, 300, 0, 50)
TextLabel.Position = UDim2.new(0.5, -150, 0, 50) -- Top Center
TextLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.BackgroundTransparency = 0.5
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextSize = 20
TextLabel.Font = Enum.Font.SourceSansBold
TextLabel.Text = "Loading Game Info..."

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = TextLabel

local MarketplaceService = game:GetService("MarketplaceService")
local success, info = pcall(function()
    return MarketplaceService:GetProductInfo(game.PlaceId)
end)

if success and info then
    TextLabel.Text = "📍 " .. info.Name
else
    TextLabel.Text = "❌ Unknown Game"
end
