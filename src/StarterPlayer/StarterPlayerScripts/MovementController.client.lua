local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Constants = require(ReplicatedStorage:WaitForChild("TrainSystems"):WaitForChild("Constants"))
local gameSignals = require(ReplicatedStorage:WaitForChild("GameSignals"))

local player = Players.LocalPlayer
local character
local humanoid
local currentWalkSpeed = 0
local sprinting = false

local fovTween
local camera = workspace.CurrentCamera

local function updateCharacter()
character = player.Character or player.CharacterAdded:Wait()
humanoid = character:WaitForChild("Humanoid")
humanoid.WalkSpeed = Constants.Player.WalkSpeed * (1000 / 3600 / 0.28)
end

player.CharacterAdded:Connect(function()
updateCharacter()
camera.FieldOfView = Constants.Player.DefaultFOV
end)

if player.Character then
updateCharacter()
end

local function setSprint(state)
sprinting = state
local targetSpeed = state and Constants.Player.SprintSpeed or Constants.Player.WalkSpeed
if humanoid then
humanoid.WalkSpeed = targetSpeed * (1000 / 3600 / 0.28)
end

if camera then
if fovTween then
fovTween:Cancel()
end
local targetFOV = state and Constants.Player.CameraSprintFOV or Constants.Player.DefaultFOV
fovTween = TweenService:Create(camera, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {FieldOfView = targetFOV})
fovTween:Play()
end
end

UserInputService.InputBegan:Connect(function(input, processed)
if processed then
return
end
if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonB then
setSprint(true)
elseif input.KeyCode == Enum.KeyCode.ButtonX or input.KeyCode == Enum.KeyCode.E then
gameSignals.RequestEnterTrain:FireServer()
elseif input.KeyCode == Enum.KeyCode.ButtonY or input.KeyCode == Enum.KeyCode.Q then
gameSignals.RequestExitTrain:FireServer()
end
end)

UserInputService.InputEnded:Connect(function(input)
if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonB then
setSprint(false)
end
end)

RunService.RenderStepped:Connect(function()
if not humanoid then
return
end
currentWalkSpeed = humanoid.MoveDirection.Magnitude * humanoid.WalkSpeed
end)

return {
IsSprinting = function()
return sprinting
end,
GetSpeed = function()
return currentWalkSpeed
end,
}
