local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TrainFactory = require(ReplicatedStorage:WaitForChild("TrainSystems"):WaitForChild("TrainFactory"))
local yardBuilder = require(script.Parent:WaitForChild("YardBuilder"))
local playerStates = require(script.Parent:WaitForChild("GameState"))
local gameSignals = require(ReplicatedStorage:WaitForChild("GameSignals"))

local trains = {}

local function spawnTrains()
local spawnPositions = {
Vector3.new(150, 2, 120),
Vector3.new(90, 2, 120),
}

local simpleTrain, simplePhysics = TrainFactory.createTrain("PracticeDriver", spawnPositions[1], {
MaxSpeedKmh = 65,
AccelerationRate = 16,
BrakeRate = 45,
IsAdvanced = true,
SteamOverrides = {
Coal = 120,
Water = 110,
},
})

local advancedTrain, advancedPhysics = TrainFactory.createTrain("SteamAdvanced", spawnPositions[2], {
MaxSpeedKmh = 75,
AccelerationRate = 15,
BrakeRate = 40,
IsAdvanced = true,
SteamOverrides = {
Coal = 100,
Water = 90,
},
})

trains[simpleTrain.Name] = simplePhysics
trains[advancedTrain.Name] = advancedPhysics
end

spawnTrains()

local function releasePlayer(player)
local state = playerStates[player]
if state and state.ActiveTrain then
local seat = state.ActiveTrain.Seat
if seat and seat.Occupant then
seat:Sit(nil)
end
state.ActiveTrain = nil
end
end

Players.PlayerRemoving:Connect(releasePlayer)

gameSignals.RequestEnterTrain.OnServerEvent:Connect(function(player)
local state = playerStates[player]
if not state then
return
end

for _, train in pairs(trains) do
local seat = train.Seat
if seat and not seat.Occupant then
seat:Sit(player.Character and player.Character:FindFirstChild("Humanoid"))
state.ActiveTrain = train
break
end
end
end)

gameSignals.RequestExitTrain.OnServerEvent:Connect(function(player)
releasePlayer(player)
end)

local trainInputEvent = gameSignals.TrainInput

trainInputEvent.OnServerEvent:Connect(function(player, payload)
local state = playerStates[player]
if not state or not state.ActiveTrain then
return
end

local train = state.ActiveTrain
if payload.Throttle then
train:SetThrottle(payload.Throttle)
end
if payload.Brake then
train:SetBrake(payload.Brake)
end

local primary = train.Model.PrimaryPart
if primary then
trainInputEvent:FireClient(player, {
Speed = primary.AssemblyLinearVelocity.Magnitude,
Steam = train.SteamState and train.SteamState:GetHUD() or nil,
})
end
end)

gameSignals.SteamCommand.OnServerEvent:Connect(function(player, payload)
local state = playerStates[player]
if not state or not state.ActiveTrain then
return
end
local train = state.ActiveTrain
local steam = train.SteamState
if not steam then
return
end

if payload.Action == "Stoke" then
steam:Stoke()
elseif payload.Action == "Injector" then
steam:ToggleInjector()
end

trainInputEvent:FireClient(player, {
Speed = train.Model.PrimaryPart.AssemblyLinearVelocity.Magnitude,
Steam = steam:GetHUD(),
})
end)

return trains
