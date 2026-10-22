--[[
	Slide Notification System (Red / White / Black theme)
	Place as a LocalScript in StarterPlayer > StarterPlayerScripts
	(or StarterGui). Call Notify(title, message, duration) in this script.
]]
 
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
 
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
 
-- THEME ---------------------------------------------------------------
local THEME = {
	Background = Color3.fromRGB(15, 15, 15),   -- black
	Accent     = Color3.fromRGB(255, 255, 255),  -- red
	Text       = Color3.fromRGB(255, 255, 255),-- white
	SubText    = Color3.fromRGB(190, 190, 190),
}
 
local WIDTH, HEIGHT = 300, 76
local SPACING = 8
local SLIDE_TIME = 0.45
 
-- GUI ROOT ------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "NotificationGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui
 
local container = Instance.new("Frame")
container.Name = "Container"
container.AnchorPoint = Vector2.new(1, 1)
container.Position = UDim2.new(1, -16, 1, -16)
container.Size = UDim2.new(0, WIDTH, 1, -32)
container.BackgroundTransparency = 1
container.Parent = gui
 
local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
layout.Padding = UDim.new(0, SPACING)
layout.Parent = container
 
local counter = 0
 
-- NOTIFY --------------------------------------------------------------
local function Notify(title, message, duration)
	title = tostring(title or "Notification")
	message = tostring(message or "")
	duration = duration or 4
 
	counter += 1
 
	-- Wrapper holds the layout slot; inner frame slides.
	local wrapper = Instance.new("Frame")
	wrapper.Name = "Notif_" .. counter
	wrapper.LayoutOrder = counter
	wrapper.Size = UDim2.new(1, 0, 0, HEIGHT)
	wrapper.BackgroundTransparency = 1
	wrapper.ClipsDescendants = false
	wrapper.Parent = container
 
	local card = Instance.new("Frame")
	card.Name = "Card"
	card.Size = UDim2.new(1, 0, 1, 0)
	card.Position = UDim2.new(1.3, 0, 0, 0) -- start off-screen right
	card.BackgroundColor3 = THEME.Background
	card.BorderSizePixel = 0
	card.Parent = wrapper
 
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = card
 
	local stroke = Instance.new("UIStroke")
	stroke.Color = THEME.Accent
	stroke.Thickness = 1.5
	stroke.Parent = card
 
	-- Red accent bar (left)
	local bar = Instance.new("Frame")
	bar.Name = "AccentBar"
	bar.Size = UDim2.new(0, 5, 1, 0)
	bar.BackgroundColor3 = THEME.Accent
	bar.BorderSizePixel = 0
	bar.Parent = card
 
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 8)
	barCorner.Parent = bar
 
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.new(0, 18, 0, 8)
	titleLabel.Size = UDim2.new(1, -30, 0, 22)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = string.upper(title)
	titleLabel.TextColor3 = THEME.Text
	titleLabel.TextSize = 15
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = card
 
	local msgLabel = Instance.new("TextLabel")
	msgLabel.Name = "Message"
	msgLabel.BackgroundTransparency = 1
	msgLabel.Position = UDim2.new(0, 18, 0, 30)
	msgLabel.Size = UDim2.new(1, -30, 0, 34)
	msgLabel.Font = Enum.Font.Gotham
	msgLabel.Text = message
	msgLabel.TextColor3 = THEME.SubText
	msgLabel.TextSize = 13
	msgLabel.TextWrapped = true
	msgLabel.TextXAlignment = Enum.TextXAlignment.Left
	msgLabel.TextYAlignment = Enum.TextYAlignment.Top
	msgLabel.Parent = card
 
	-- Timer bar (bottom, white -> shrinks)
	local timer = Instance.new("Frame")
	timer.Name = "Timer"
	timer.AnchorPoint = Vector2.new(0, 1)
	timer.Position = UDim2.new(0, 0, 1, 0)
	timer.Size = UDim2.new(1, 0, 0, 3)
	timer.BackgroundColor3 = THEME.Text
	timer.BorderSizePixel = 0
	timer.ZIndex = 2
	timer.Parent = card
 
	-- Slide in
	local slideIn = TweenService:Create(
		card,
		TweenInfo.new(SLIDE_TIME, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Position = UDim2.new(0, 0, 0, 0) }
	)
	slideIn:Play()
 
	-- Countdown bar
	TweenService:Create(
		timer,
		TweenInfo.new(duration, Enum.EasingStyle.Linear),
		{ Size = UDim2.new(0, 0, 0, 3) }
	):Play()
 
	-- Wait, then slide out and clean up
	task.delay(duration, function()
		if not card.Parent then return end
 
		local slideOut = TweenService:Create(
			card,
			TweenInfo.new(SLIDE_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
			{ Position = UDim2.new(1.3, 0, 0, 0) }
		)
		slideOut:Play()
		slideOut.Completed:Wait()
 
		-- Collapse the slot smoothly so others slide down
		local collapse = TweenService:Create(
			wrapper,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad),
			{ Size = UDim2.new(1, 0, 0, 0) }
		)
		collapse:Play()
		collapse.Completed:Wait()
		wrapper:Destroy()
	end)
end
 
return Notify
