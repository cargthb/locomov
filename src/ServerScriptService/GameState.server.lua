local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local gameSignals = require(ReplicatedStorage:WaitForChild("GameSignals"))

local playerStates = {}

local function onPlayerAdded(player)
playerStates[player] = {
HasStarted = false,
ActiveTrain = nil,
}
end

local function onPlayerRemoving(player)
playerStates[player] = nil
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
onPlayerAdded(player)
end

gameSignals.RequestStart.OnServerEvent:Connect(function(player)
local state = playerStates[player]
if state and not state.HasStarted then
state.HasStarted = true
end
end)

return playerStates
