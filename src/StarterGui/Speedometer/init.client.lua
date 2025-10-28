local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Constants = require(ReplicatedStorage:WaitForChild("TrainSystems"):WaitForChild("Constants"))
local gameSignals = require(ReplicatedStorage:WaitForChild("GameSignals"))
local trainHUDSignal = gameSignals.TrainInput

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedometerGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 2
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(1, 1)
frame.Position = UDim2.new(1, -40, 1, -40)
frame.Size = UDim2.new(0, 180, 0, 90)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.35
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

local speedLabel = Instance.new("TextLabel")
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.TextScaled = true
speedLabel.Size = UDim2.new(1, -20, 0.6, 0)
speedLabel.Position = UDim2.new(0, 10, 0, 10)
speedLabel.Text = "0"
speedLabel.Parent = frame

local unitLabel = Instance.new("TextLabel")
unitLabel.BackgroundTransparency = 1
unitLabel.Font = Enum.Font.Gotham
unitLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
unitLabel.TextScaled = true
unitLabel.Size = UDim2.new(1, -20, 0.35, 0)
unitLabel.Position = UDim2.new(0, 10, 0.6, 0)
unitLabel.Text = "km/h"
unitLabel.Parent = frame

local cabFrame = Instance.new("Frame")
cabFrame.AnchorPoint = Vector2.new(1, 1)
cabFrame.Position = UDim2.new(1, -240, 1, -40)
cabFrame.Size = UDim2.new(0, 220, 0, 140)
cabFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
cabFrame.BackgroundTransparency = 0.45
cabFrame.Visible = false
cabFrame.Parent = screenGui

local cabCorner = Instance.new("UICorner")
cabCorner.CornerRadius = UDim.new(0, 14)
cabCorner.Parent = cabFrame

local cabHeader = Instance.new("TextLabel")
cabHeader.BackgroundTransparency = 1
cabHeader.Font = Enum.Font.GothamBold
cabHeader.TextColor3 = Color3.fromRGB(230, 230, 230)
cabHeader.TextScaled = true
cabHeader.Size = UDim2.new(1, -20, 0, 28)
cabHeader.Position = UDim2.new(0, 10, 0, 10)
cabHeader.Text = "Cab Systems"
cabHeader.Parent = cabFrame

local cabList = Instance.new("TextLabel")
cabList.BackgroundTransparency = 1
cabList.Font = Enum.Font.Gotham
cabList.TextColor3 = Color3.fromRGB(200, 200, 200)
cabList.TextScaled = false
cabList.TextSize = 18
cabList.TextWrapped = true
cabList.TextXAlignment = Enum.TextXAlignment.Left
cabList.TextYAlignment = Enum.TextYAlignment.Top
cabList.Position = UDim2.new(0, 10, 0, 44)
cabList.Size = UDim2.new(1, -20, 1, -54)
cabList.Text = "Coal: 0%\nWater: 0%\nPressure: 0 bar\nFire: 0°C\nInjector: Off"
cabList.Parent = cabFrame

local currentSpeed = 0
local targetSpeed = 0
local smoothing = 10

local function studsPerSecondToKmh(spd)
return spd * 0.28 * 3.6
end

local function setSpeedFromStuds(studsPerSecond)
targetSpeed = studsPerSecondToKmh(studsPerSecond)
end

local function updateCabDisplay(data)
if not data then
cabFrame.Visible = false
return
end
cabFrame.Visible = true
local injectorState = data.InjectorOn and "On" or "Off"
local warning = data.Warning and ("\nWarning: " .. data.Warning) or ""
cabList.Text = string.format("Coal: %d%%\nWater: %d%%\nPressure: %d bar\nFire: %d°C\nInjector: %s%s",
math.floor(data.Coal + 0.5),
math.floor(data.Water + 0.5),
math.floor(data.Pressure + 0.5),
math.floor(data.FireTemperature + 0.5),
injectorState,
warning
)
end

RunService.RenderStepped:Connect(function(dt)
currentSpeed = currentSpeed + (targetSpeed - currentSpeed) * math.min(1, dt * smoothing)
speedLabel.Text = string.format("%d", math.floor(currentSpeed + 0.5))
end)

trainHUDSignal.OnClientEvent:Connect(function(data)
if data and data.Speed then
setSpeedFromStuds(data.Speed)
end
if data and data.Steam then
updateCabDisplay(data.Steam)
else
updateCabDisplay(nil)
end
end)

local function characterAdded(char)
local humanoid = char:WaitForChild("Humanoid")
RunService.RenderStepped:Connect(function()
local seatPart = humanoid.SeatPart
if seatPart and seatPart:IsDescendantOf(Workspace) then
setSpeedFromStuds(seatPart.AssemblyLinearVelocity.Magnitude)
else
targetSpeed = studsPerSecondToKmh(humanoid.MoveDirection.Magnitude * humanoid.WalkSpeed)
end
end)

humanoid.Seated:Connect(function(active)
if not active then
updateCabDisplay(nil)
end
end)
end

player.CharacterAdded:Connect(characterAdded)
if player.Character then
characterAdded(player.Character)
end

return {
SetTrainSpeed = function(spd)
setSpeedFromStuds(spd)
end,
}
