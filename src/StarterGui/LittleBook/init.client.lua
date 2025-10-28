local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LittleBookGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 5
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Name = "BookFrame"
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Size = UDim2.new(0, 520, 0, 360)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(235, 223, 203)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 16)
uiCorner.Parent = frame

local outline = Instance.new("UIStroke")
outline.Color = Color3.fromRGB(149, 131, 102)
outline.Thickness = 2
outline.Parent = frame

local header = Instance.new("TextLabel")
header.BackgroundTransparency = 1
header.Size = UDim2.new(1, -40, 0, 40)
header.Position = UDim2.new(0, 20, 0, 20)
header.Font = Enum.Font.GothamBold
header.Text = "Little Book"
header.TextScaled = true
header.TextColor3 = Color3.fromRGB(45, 40, 30)
header.Parent = frame

local pageContainer = Instance.new("Frame")
pageContainer.Name = "PageContainer"
pageContainer.BackgroundTransparency = 1
pageContainer.Size = UDim2.new(1, -40, 1, -140)
pageContainer.Position = UDim2.new(0, 20, 0, 80)
pageContainer.Parent = frame

local pageText = Instance.new("TextLabel")
pageText.Name = "PageText"
pageText.BackgroundTransparency = 1
pageText.Font = Enum.Font.Gotham
pageText.TextColor3 = Color3.fromRGB(55, 50, 40)
pageText.TextWrapped = true
pageText.TextXAlignment = Enum.TextXAlignment.Left
pageText.TextYAlignment = Enum.TextYAlignment.Top
pageText.Size = UDim2.new(1, 0, 1, 0)
pageText.TextScaled = false
pageText.TextSize = 20
pageText.Parent = pageContainer

local pageIndicator = Instance.new("TextLabel")
pageIndicator.BackgroundTransparency = 1
pageIndicator.Font = Enum.Font.GothamSemibold
pageIndicator.TextColor3 = Color3.fromRGB(65, 60, 50)
pageIndicator.Size = UDim2.new(0, 150, 0, 30)
pageIndicator.Position = UDim2.new(0.5, -75, 1, -50)
pageIndicator.TextScaled = true
pageIndicator.Parent = frame

local prevButton = Instance.new("TextButton")
prevButton.Text = "<"
prevButton.Size = UDim2.new(0, 80, 0, 36)
prevButton.Position = UDim2.new(0, 30, 1, -60)
prevButton.BackgroundColor3 = Color3.fromRGB(216, 192, 160)
prevButton.TextScaled = true
prevButton.Font = Enum.Font.GothamBold
prevButton.TextColor3 = Color3.fromRGB(40, 35, 25)
prevButton.Parent = frame

local nextButton = Instance.new("TextButton")
nextButton.Text = ">"
nextButton.Size = UDim2.new(0, 80, 0, 36)
nextButton.Position = UDim2.new(1, -110, 1, -60)
nextButton.AnchorPoint = Vector2.new(0, 0)
nextButton.BackgroundColor3 = prevButton.BackgroundColor3
nextButton.TextScaled = true
nextButton.Font = Enum.Font.GothamBold
nextButton.TextColor3 = prevButton.TextColor3
nextButton.Parent = frame

local hintLabel = Instance.new("TextLabel")
hintLabel.BackgroundTransparency = 1
hintLabel.Size = UDim2.new(1, -40, 0, 24)
hintLabel.Position = UDim2.new(0, 20, 1, -30)
hintLabel.Font = Enum.Font.Gotham
hintLabel.Text = "Press B / D-Pad Up to toggle"
hintLabel.TextScaled = true
hintLabel.TextColor3 = Color3.fromRGB(90, 80, 60)
hintLabel.Parent = frame

local bookPages = {
{
title = "Welcome",
text = "Welcome to TESTLOCOMOTIVA by C.RELLA. This sandbox yard lets you study and test steam locomotives in a Roblox-inspired environment. Start by reading these quick notes, then step into the yard and explore!",
},
{
title = "Controls",
text = "Walk: WASD / Left Stick\nSprint: Hold Shift / Button B\nInteract: E / Button X\nExit Train: Q / Circle\nThrottle: W/S or RT/LT\nBrake: Space / LB\nWhistle: H / RB\nCamera: C / Right Stick Click",
},
{
title = "Practice Tracks",
text = "Ahead of spawn you will find 10 empty, parallel track lanes. They are reserved for experimenting with future switches and custom track pieces. No trains spawn there so you can build freely.",
},
{
title = "Train Types",
text = "To your left is the static showcase: a low-poly loco, a medium build, and a high-detail reference model. To your right is the drivable loop holding two operational locomotives (standard and advanced steam versions).",
},
{
title = "Driving Basics",
text = "Enter a cab with E. Use throttle to accelerate and Space to brake. Tap H for whistle, C to switch first/third person. Stay within the loop and mind the buffers at each end.",
},
{
title = "Steam Systems",
text = "The advanced locomotives model coal, water, boiler pressure, and fire temperature. Stoke the fire (F) to add coal, toggle the injector (R) to add water, and monitor the cab gauges. Safety valves lift automatically when pressure is high.",
},
{
title = "Troubleshooting",
text = "Train stuck? Reduce throttle, apply brake, then release slowly. If pressure collapses, add coal and wait for steam to build. Low water locks the throttle until the injector restores safe levels.",
},
}

local currentIndex = 1

local function renderPage()
local page = bookPages[currentIndex]
pageText.Text = string.format("%s\n\n%s", page.title, page.text)
pageIndicator.Text = string.format("Page %d / %d", currentIndex, #bookPages)
end

renderPage()

local function toggle(nextState)
if nextState == nil then
screenGui.Enabled = not screenGui.Enabled
else
screenGui.Enabled = nextState
end
end

prevButton.MouseButton1Click:Connect(function()
currentIndex -= 1
if currentIndex < 1 then
currentIndex = #bookPages
end
renderPage()
end)

nextButton.MouseButton1Click:Connect(function()
currentIndex += 1
if currentIndex > #bookPages then
currentIndex = 1
end
renderPage()
end)

UserInputService.InputBegan:Connect(function(input, processed)
if processed then
return
end

if input.KeyCode == Enum.KeyCode.B or input.KeyCode == Enum.KeyCode.DPadUp then
toggle()
elseif input.KeyCode == Enum.KeyCode.ButtonX then
toggle()
end
end)

-- Book opens automatically at spawn and remains visible until dismissed
screenGui.Enabled = true

return {
Toggle = toggle,
}
