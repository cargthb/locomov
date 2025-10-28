local module = {}

local container = script

local function ensureRemote(name, className)
local existing = container:FindFirstChild(name)
if existing and existing:IsA(className) then
return existing
end
local remote = Instance.new(className)
remote.Name = name
remote.Parent = container
return remote
end

module.RequestStart = ensureRemote("RequestStart", "RemoteEvent")
module.ToggleSprint = ensureRemote("ToggleSprint", "RemoteEvent")
module.RequestEnterTrain = ensureRemote("RequestEnterTrain", "RemoteEvent")
module.RequestExitTrain = ensureRemote("RequestExitTrain", "RemoteEvent")
module.TrainInput = ensureRemote("TrainInput", "RemoteEvent")
module.SteamCommand = ensureRemote("SteamCommand", "RemoteEvent")
module.CameraMode = ensureRemote("CameraMode", "RemoteEvent")

return module
