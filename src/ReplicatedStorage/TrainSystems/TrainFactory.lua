local Workspace = game:GetService("Workspace")

local Constants = require(script.Parent.Constants)
local SteamSimulation = require(script.Parent.SteamSimulation)
local TrainPhysics = require(script.Parent.TrainPhysics)

local TrainFactory = {}

local function createBoiler(parent, length, radius, offset)
local boiler = Instance.new("Part")
boiler.Shape = Enum.PartType.Cylinder
boiler.Name = "Boiler"
boiler.Size = Vector3.new(radius * 2, length, radius * 2)
boiler.Material = Enum.Material.Metal
boiler.Color = Color3.fromRGB(45, 45, 45)
boiler.CFrame = parent.PrimaryPart.CFrame * CFrame.new(offset) * CFrame.Angles(0, 0, math.rad(90))
boiler.Parent = parent
local weld = Instance.new("WeldConstraint")
weld.Part0 = parent.PrimaryPart
weld.Part1 = boiler
weld.Parent = boiler
return boiler
end

function TrainFactory.createTrain(name, position, options)
options = options or {}
local model = Instance.new("Model")
model.Name = name

local base = Instance.new("Part")
base.Name = "Chassis"
base.Size = Vector3.new(14, 1.4, 4)
base.Material = Enum.Material.Metal
base.Color = Color3.fromRGB(30, 30, 30)
base.CFrame = CFrame.new(position)
base.Anchored = false
base.Parent = model
model.PrimaryPart = base

local cab = Instance.new("Part")
cab.Name = "Cab"
cab.Size = Vector3.new(5, 5, 4)
cab.Material = Enum.Material.Metal
cab.Color = Color3.fromRGB(60, 60, 60)
cab.CFrame = base.CFrame * CFrame.new(-4.5, 2.7, 0)
cab.Parent = model
local cabWeld = Instance.new("WeldConstraint")
cabWeld.Part0 = base
cabWeld.Part1 = cab
cabWeld.Parent = cab

local boiler = createBoiler(model, 12, 2.8, Vector3.new(2.5, 2.2, 0))

for _, offset in ipairs({Vector3.new(-5, -1.4, -1.5), Vector3.new(-5, -1.4, 1.5), Vector3.new(0, -1.4, -1.5), Vector3.new(0, -1.4, 1.5), Vector3.new(5, -1.4, -1.5), Vector3.new(5, -1.4, 1.5)}) do
local wheel = Instance.new("Part")
wheel.Shape = Enum.PartType.Cylinder
wheel.Size = Vector3.new(1.2, 4, 4)
wheel.Material = Enum.Material.Metal
wheel.Color = Color3.fromRGB(80, 80, 80)
wheel.Anchored = false
wheel.CFrame = base.CFrame * CFrame.new(offset) * CFrame.Angles(0, 0, math.rad(90))
wheel.Parent = model
local weld = Instance.new("WeldConstraint")
weld.Part0 = base
weld.Part1 = wheel
weld.Parent = wheel
end

local seat = Instance.new("VehicleSeat")
seat.Name = "DriverSeat"
seat.CFrame = base.CFrame * CFrame.new(-4.5, 2.2, 0)
seat.MaxSpeed = 0
seat.Disabled = false
seat.Parent = model

local cameraSeat = Instance.new("Seat")
cameraSeat.Name = "ObservationSeat"
cameraSeat.CFrame = base.CFrame * CFrame.new(2, 3.2, -4)
cameraSeat.Transparency = 1
cameraSeat.CanCollide = false
cameraSeat.Parent = model

local frontBuffer = Instance.new("Part")
frontBuffer.Name = "FrontBuffer"
frontBuffer.Size = Vector3.new(1, 2, 6)
frontBuffer.Color = Color3.fromRGB(90, 30, 30)
frontBuffer.Material = Enum.Material.Metal
frontBuffer.CFrame = base.CFrame * CFrame.new(7, 1, 0)
frontBuffer.Parent = model
local frontWeld = Instance.new("WeldConstraint")
frontWeld.Part0 = base
frontWeld.Part1 = frontBuffer
frontWeld.Parent = frontBuffer

local config = {
MaxSpeedKmh = options.MaxSpeedKmh or Constants.Train.MaxSpeedKmh,
AccelerationRate = options.AccelerationRate or Constants.Train.AccelerationRate,
BrakeRate = options.BrakeRate or Constants.Train.BrakeRate,
Identifier = name,
IsAdvanced = options.IsAdvanced,
}

local physics = TrainPhysics.new(model, config)

if options.IsAdvanced then
local sim = SteamSimulation.new(name, options.SteamOverrides)
sim.Train = physics
physics.SteamState = sim
end

model.Parent = Workspace

return model, physics
end

return TrainFactory
