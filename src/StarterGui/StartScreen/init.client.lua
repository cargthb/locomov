local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gameSignals = require(ReplicatedStorage:WaitForChild("GameSignals"))

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StartScreen"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 10
screenGui.Parent = playerGui

local background = Instance.new("Frame")
background.Name = "Background"
background.BackgroundColor3 = Color3.fromRGB(245, 230, 204)
background.Size = UDim2.fromScale(1, 1)
background.Parent = screenGui

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, 0, 0, 120)
title.Position = UDim2.new(0, 0, 0.35, -60)
title.Font = Enum.Font.GothamBold
title.Text = "TESTLOCOMOTIVA"
title.TextColor3 = Color3.fromRGB(25, 25, 25)
title.TextScaled = true
title.Parent = background

local credit = Instance.new("TextLabel")
credit.Name = "Credit"
credit.BackgroundTransparency = 1
credit.Size = UDim2.new(1, 0, 0, 50)
credit.Position = UDim2.new(0, 0, 0.45, 0)
credit.Font = Enum.Font.GothamSemibold
credit.Text = "by C.RELLA"
credit.TextColor3 = Color3.fromRGB(40, 40, 40)
credit.TextScaled = true
credit.Parent = background

local startButton = Instance.new("TextButton")
startButton.Name = "StartButton"
startButton.Size = UDim2.new(0, 240, 0, 70)
startButton.Position = UDim2.new(0.5, -120, 0.62, 0)
startButton.BackgroundColor3 = Color3.fromRGB(216, 192, 160)
startButton.AutoButtonColor = true
startButton.Text = "Start"
startButton.TextScaled = true
startButton.Font = Enum.Font.GothamBold
startButton.TextColor3 = Color3.fromRGB(30, 30, 30)
startButton.Parent = background

local bookToggleHint = Instance.new("TextLabel")
bookToggleHint.Name = "BookHint"
bookToggleHint.BackgroundTransparency = 1
bookToggleHint.Size = UDim2.new(1, 0, 0, 30)
bookToggleHint.Position = UDim2.new(0, 0, 0.72, 0)
bookToggleHint.Font = Enum.Font.Gotham
bookToggleHint.Text = "Press B to open the Little Book"
bookToggleHint.TextColor3 = Color3.fromRGB(60, 60, 60)
bookToggleHint.TextScaled = true
bookToggleHint.Parent = background

local startEvent = gameSignals.RequestStart

local hasStarted = false

local function fadeOut()
if hasStarted then
return
end
hasStarted = true

local tween = TweenService:Create(background, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
BackgroundTransparency = 1,
})
local childTweens = {}
for _, child in ipairs(background:GetChildren()) do
if child:IsA("TextLabel") or child:IsA("TextButton") then
childTweens[#childTweens + 1] = TweenService:Create(child, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
TextTransparency = 1,
BackgroundTransparency = 1,
})
end
end

tween:Play()
for _, tweenObj in ipairs(childTweens) do
tweenObj:Play()
end

tween.Completed:Wait()
screenGui.Enabled = false
screenGui:Destroy()
end

local function begin()
if not hasStarted then
startEvent:FireServer()
fadeOut()
end
end

startButton.MouseButton1Click:Connect(begin)

UserInputService.InputBegan:Connect(function(input, processed)
if processed or hasStarted then
return
end

if input.UserInputType == Enum.UserInputType.Gamepad1 then
if input.KeyCode == Enum.KeyCode.ButtonA then
begin()
end
elseif input.UserInputType == Enum.UserInputType.Touch then
local touchPos = input.Position
local absPos = startButton.AbsolutePosition
local absSize = startButton.AbsoluteSize
if touchPos.X >= absPos.X and touchPos.X <= absPos.X + absSize.X and touchPos.Y >= absPos.Y and touchPos.Y <= absPos.Y + absSize.Y then
begin()
end
elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter or input.KeyCode == Enum.KeyCode.Space then
begin()
end
end)

startButton.SelectionGained:Connect(function()
startButton.BackgroundColor3 = Color3.fromRGB(226, 202, 170)
end)

startButton.SelectionLost:Connect(function()
startButton.BackgroundColor3 = Color3.fromRGB(216, 192, 160)
end)
