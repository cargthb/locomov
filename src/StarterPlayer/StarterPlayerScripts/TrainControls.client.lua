local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local signals = require(ReplicatedStorage:WaitForChild("GameSignals"))
local trainInput = signals.TrainInput
local steamCommand = signals.SteamCommand

local throttle = 0
local brake = 0
local inTrain = false
local cameraMode = "FirstPerson"
local camera = Workspace.CurrentCamera

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
camera = Workspace.CurrentCamera
end)

local function updateTrainInput()
if not inTrain then
return
end
trainInput:FireServer({
Throttle = throttle,
Brake = brake,
})
end

local function processMovement(actionName, inputState, inputObject)
if not inTrain then
return Enum.ContextActionResult.Pass
end

if actionName == "TrainThrottle" then
if inputState == Enum.UserInputState.Begin then
throttle = math.clamp(throttle + 0.2, -1, 1)
elseif inputState == Enum.UserInputState.End then
-- no-op
end
updateTrainInput()
return Enum.ContextActionResult.Sink
elseif actionName == "TrainBrake" then
if inputState == Enum.UserInputState.Begin then
brake = math.clamp(brake + 0.25, 0, 1)
elseif inputState == Enum.UserInputState.End then
brake = math.max(0, brake - 0.25)
end
updateTrainInput()
return Enum.ContextActionResult.Sink
elseif actionName == "TrainThrottleDown" then
if inputState == Enum.UserInputState.Begin then
throttle = math.clamp(throttle - 0.2, -1, 1)
updateTrainInput()
end
return Enum.ContextActionResult.Sink
elseif actionName == "TrainWhistle" then
if inputState == Enum.UserInputState.Begin then
local seat = player.Character and player.Character:FindFirstChildWhichIsA("Humanoid") and player.Character.Humanoid.SeatPart
if seat and seat.Parent then
local whistle = seat.Parent:FindFirstChild("Whistle", true)
if whistle and whistle:IsA("Sound") then
whistle:Play()
end
end
end
return Enum.ContextActionResult.Sink
elseif actionName == "TrainStoke" then
if inputState == Enum.UserInputState.Begin then
steamCommand:FireServer({Action = "Stoke"})
end
return Enum.ContextActionResult.Sink
elseif actionName == "TrainInjector" then
if inputState == Enum.UserInputState.Begin then
steamCommand:FireServer({Action = "Injector"})
end
return Enum.ContextActionResult.Sink
elseif actionName == "TrainCamera" then
if inputState == Enum.UserInputState.Begin then
cameraMode = cameraMode == "FirstPerson" and "ThirdPerson" or "FirstPerson"
end
return Enum.ContextActionResult.Sink
end

return Enum.ContextActionResult.Pass
end

ContextActionService:BindAction("TrainThrottle", processMovement, true, Enum.KeyCode.W, Enum.KeyCode.ButtonR2)
ContextActionService:BindAction("TrainThrottleDown", processMovement, true, Enum.KeyCode.S, Enum.KeyCode.ButtonL2)
ContextActionService:BindAction("TrainBrake", processMovement, true, Enum.KeyCode.Space, Enum.KeyCode.ButtonL1)
ContextActionService:BindAction("TrainWhistle", processMovement, true, Enum.KeyCode.H, Enum.KeyCode.ButtonR1)
ContextActionService:BindAction("TrainStoke", processMovement, true, Enum.KeyCode.F, Enum.KeyCode.ButtonX)
ContextActionService:BindAction("TrainInjector", processMovement, true, Enum.KeyCode.R, Enum.KeyCode.ButtonY)
ContextActionService:BindAction("TrainCamera", processMovement, true, Enum.KeyCode.C, Enum.KeyCode.ButtonR3)

RunService.RenderStepped:Connect(function()
local seatPart = humanoid.SeatPart
if seatPart and seatPart:IsDescendantOf(Workspace) then
if not inTrain then
inTrain = true
end

if cameraMode == "FirstPerson" then
camera.CameraSubject = humanoid
camera.CameraType = Enum.CameraType.Custom
elseif seatPart then
camera.CameraType = Enum.CameraType.Scriptable
local basePart = seatPart.Parent and seatPart.Parent.PrimaryPart or seatPart
if basePart then
local cframe = basePart.CFrame * CFrame.new(0, 6, 18)
camera.CFrame = CFrame.lookAt(cframe.Position, basePart.Position + basePart.CFrame.LookVector * 40)
end
end
else
if inTrain then
inTrain = false
throttle = 0
brake = 1
end
cameraMode = "FirstPerson"
camera.CameraType = Enum.CameraType.Custom
end
end)

humanoid.Seated:Connect(function(active, seat)
inTrain = active
if active then
updateTrainInput()
else
throttle = 0
brake = 1
updateTrainInput()
end
end)
