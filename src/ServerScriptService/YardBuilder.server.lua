local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local Constants = require(ReplicatedStorage:WaitForChild("TrainSystems"):WaitForChild("Constants"))

local yardModel = Instance.new("Folder")
yardModel.Name = "TESTLOCOMOTIVA_Yard"
yardModel.Parent = Workspace

local function setupLighting()
Lighting.Brightness = 2.3
Lighting.ClockTime = 13
Lighting.EnvironmentDiffuseScale = 0.3
Lighting.EnvironmentSpecularScale = 0.4
Lighting.Ambient = Color3.fromRGB(180, 180, 180)
Lighting.OutdoorAmbient = Color3.fromRGB(195, 195, 195)
end

local function createGround()
local ground = Instance.new("Part")
ground.Name = "YardFloor"
ground.Size = Vector3.new(800, 2, 600)
ground.Anchored = true
ground.Position = Vector3.new(0, -1, 0)
ground.Material = Enum.Material.Grass
ground.Color = Color3.fromRGB(106, 135, 89)
ground.Parent = yardModel
return ground
end

local function createPracticeTracks(origin)
local container = Instance.new("Folder")
container.Name = "PracticeTracks"
container.Parent = yardModel

local spacing = Constants.Track.PracticeLaneSpacing
local length = Constants.Track.PracticeLaneLength

for lane = 1, Constants.Track.PracticeLaneCount do
local laneModel = Instance.new("Model")
laneModel.Name = string.format("PracticeLane_%02d", lane)
laneModel.Parent = container
local offset = (lane - (Constants.Track.PracticeLaneCount + 1) / 2) * spacing
local laneOrigin = origin + Vector3.new(offset, 0, 0)

local sleeperCount = math.floor(length / Constants.Track.SleeperSpacing)
for i = 0, sleeperCount do
local sleeper = Instance.new("Part")
sleeper.Name = "Sleeper"
sleeper.Size = Vector3.new(Constants.Track.PracticeLaneWidth, 0.4, 1.4)
sleeper.Anchored = true
sleeper.Material = Enum.Material.WoodPlanks
sleeper.Color = Color3.fromRGB(125, 95, 65)
sleeper.CFrame = CFrame.new(laneOrigin + Vector3.new(0, 0, -length / 2 + i * Constants.Track.SleeperSpacing))
sleeper.Parent = laneModel
end

for railIndex = 1, 2 do
local rail = Instance.new("Part")
rail.Name = "Rail"
rail.Anchored = true
rail.Material = Enum.Material.Metal
rail.Color = Color3.fromRGB(120, 120, 120)
rail.Size = Vector3.new(Constants.Track.RailWidth, Constants.Track.RailHeight, length)
local railOffset = (railIndex == 1) and -1.2 or 1.2
rail.CFrame = CFrame.new(laneOrigin + Vector3.new(railOffset, 0.2, 0)) * CFrame.Angles(math.rad(90), 0, 0)
rail.Parent = laneModel
end
end

return container
end

local function createStaticShowcase(origin)
local container = Instance.new("Folder")
container.Name = "StaticShowcase"
container.Parent = yardModel

local detailLevels = {"Low", "Medium", "High"}
for index, detail in ipairs(detailLevels) do
local model = Instance.new("Model")
model.Name = detail .. "DetailTrain"
model.Parent = container

local base = Instance.new("Part")
base.Name = "DisplayBase"
base.Size = Vector3.new(20, 0.4, 80)
base.Anchored = true
base.Material = Enum.Material.Concrete
base.Color = Color3.fromRGB(100, 100, 100)
base.CFrame = CFrame.new(origin + Vector3.new((index - 2) * 30, -0.8, 0))
base.Parent = model

local body = Instance.new("Part")
body.Name = "Body"
body.Size = Vector3.new(8 + index * 2, 6 + index, 18 + index * 4)
body.Anchored = true
body.Material = Enum.Material.Metal
body.Color = Color3.fromRGB(50 + index * 30, 50 + index * 25, 50 + index * 20)
body.CFrame = CFrame.new(base.Position + Vector3.new(0, body.Size.Y / 2 + 0.4, 0))
body.Parent = model

for wheelIndex = -1, 1, 2 do
local wheelPart = Instance.new("Part")
wheelPart.Name = "Wheel"
wheelPart.Size = Vector3.new(2.5, 2.5, 1)
wheelPart.Anchored = true
wheelPart.Material = Enum.Material.Metal
wheelPart.Color = Color3.fromRGB(60, 60, 60)
wheelPart.CFrame = CFrame.new(body.Position + Vector3.new(wheelIndex * (3 + index * 0.3), -body.Size.Y / 2 + 1.5, -body.Size.Z / 4)) * CFrame.Angles(0, 0, math.rad(90))
local mesh = Instance.new("SpecialMesh")
mesh.MeshType = Enum.MeshType.Cylinder
mesh.Scale = Vector3.new(1.4, 1.4, 0.3)
mesh.Parent = wheelPart
wheelPart.Parent = model

local rearWheel = wheelPart:Clone()
rearWheel.CFrame = CFrame.new(body.Position + Vector3.new(wheelIndex * (3 + index * 0.3), -body.Size.Y / 2 + 1.5, body.Size.Z / 4)) * CFrame.Angles(0, 0, math.rad(90))
rearWheel.Parent = model
end

if detail ~= "Low" then
local boiler = Instance.new("Part")
boiler.Shape = Enum.PartType.Cylinder
boiler.Size = Vector3.new(body.Size.X * 0.6, body.Size.Z, body.Size.Z)
boiler.Anchored = true
boiler.Material = Enum.Material.Metal
boiler.Color = Color3.fromRGB(40 + index * 25, 40 + index * 20, 45 + index * 18)
boiler.CFrame = body.CFrame * CFrame.new(0, body.Size.Y * 0.3, 0) * CFrame.Angles(0, 0, math.rad(90))
boiler.Parent = model
end

if detail == "High" then
local cab = Instance.new("Part")
cab.Name = "Cab"
cab.Size = Vector3.new(body.Size.X * 0.8, body.Size.Y * 0.8, body.Size.Z * 0.4)
cab.Anchored = true
cab.Material = Enum.Material.Metal
cab.Color = Color3.fromRGB(35, 35, 35)
cab.CFrame = body.CFrame * CFrame.new(0, cab.Size.Y / 2, body.Size.Z / 3)
cab.Parent = model
local detailPipe = Instance.new("Part")
detailPipe.Shape = Enum.PartType.Cylinder
detailPipe.Size = Vector3.new(0.6, body.Size.Z, 0.6)
detailPipe.Anchored = true
detailPipe.Material = Enum.Material.Metal
detailPipe.Color = Color3.fromRGB(120, 120, 120)
detailPipe.CFrame = body.CFrame * CFrame.new(body.Size.X * 0.35, body.Size.Y * 0.4, 0) * CFrame.Angles(0, 0, math.rad(90))
detailPipe.Parent = model

local rods = Instance.new("Part")
rods.Size = Vector3.new(body.Size.X * 0.9, 0.3, 0.3)
rods.Anchored = true
rods.Material = Enum.Material.Metal
rods.Color = Color3.fromRGB(160, 160, 160)
rods.CFrame = body.CFrame * CFrame.new(0, -body.Size.Y * 0.35, 0)
rods.Parent = model
end
end

return container
end

local function createLoopTrack(origin)
local container = Instance.new("Model")
container.Name = "DriverLoop"
container.Parent = yardModel

local radius = Constants.Track.LoopRadius
local straight = Constants.Track.LoopStraightLength
local segments = 32
local angleStep = math.pi / segments

local function createRailSegment(position, rotation, length)
local rail = Instance.new("Part")
rail.Anchored = true
rail.Material = Enum.Material.Metal
rail.Color = Color3.fromRGB(120, 120, 120)
rail.Size = Vector3.new(Constants.Track.RailWidth, Constants.Track.RailHeight, length)
rail.CFrame = CFrame.new(position) * rotation
rail.Parent = container
return rail
end

local function createSleeper(position, rotation)
local sleeper = Instance.new("Part")
sleeper.Anchored = true
sleeper.Size = Vector3.new(Constants.Track.PracticeLaneWidth, 0.4, 1.4)
sleeper.Material = Enum.Material.WoodPlanks
sleeper.Color = Color3.fromRGB(125, 95, 65)
sleeper.CFrame = CFrame.new(position) * rotation
sleeper.Parent = container
return sleeper
end

local loopLength = (math.pi * radius * 2) + straight * 2
local sleeperCount = math.floor(loopLength / Constants.Track.SleeperSpacing)
local trackPoints = {}

for i = 0, sleeperCount do
local progress = i / sleeperCount
local angle = progress * math.pi
local offsetZ = (progress <= 0.5) and -straight / 2 or straight / 2
local direction = (progress <= 0.5) and -1 or 1
local center = origin + Vector3.new(0, 0, offsetZ)
local x = math.cos(angle) * radius * direction
local z = offsetZ + math.sin(angle) * radius * direction
local position = Vector3.new(center.X + x, origin.Y, center.Z + z)
local tangent = Vector3.new(-math.sin(angle) * direction, 0, math.cos(angle))
local rotation = CFrame.lookAt(position, position + tangent)
createSleeper(position, rotation)

if i % 2 == 0 then
local leftPos = position + rotation.RightVector * -1.2
local rightPos = position + rotation.RightVector * 1.2
local segmentLength = Constants.Track.SleeperSpacing * 1.1
createRailSegment(leftPos, rotation * CFrame.Angles(math.rad(90), 0, 0), segmentLength)
createRailSegment(rightPos, rotation * CFrame.Angles(math.rad(90), 0, 0), segmentLength)
end

trackPoints[#trackPoints + 1] = {Position = position, Rotation = rotation}
end

for _, offsetZ in ipairs({-straight / 2 - radius - 4, straight / 2 + radius + 4}) do
local bumper = Instance.new("Part")
bumper.Name = "Bumper"
bumper.Anchored = true
bumper.Size = Vector3.new(8, 6, 1)
bumper.Material = Enum.Material.Metal
bumper.Color = Color3.fromRGB(180, 60, 60)
bumper.CFrame = CFrame.new(origin + Vector3.new(0, 3, offsetZ))
bumper.Parent = container
end

return container, trackPoints
end

setupLighting()
local ground = createGround()
local practice = createPracticeTracks(Vector3.new(-180, 0, -40))
local showcase = createStaticShowcase(Vector3.new(220, 0, -120))
local loop, loopPoints = createLoopTrack(Vector3.new(120, 0, 120))

return {
Ground = ground,
Practice = practice,
Showcase = showcase,
Loop = loop,
LoopPoints = loopPoints,
}
