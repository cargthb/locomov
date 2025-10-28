local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local Constants = require(script.Parent.Constants)

local TrainPhysics = {}
TrainPhysics.__index = TrainPhysics

local trains = {}

local function clamp(value, min, max)
if value < min then
return min
elseif value > max then
return max
end
return value
end

local function kmhToStudsPerSecond(speedKmh)
return speedKmh * 1000 / 3600 / 0.28 -- 1 stud ~ 0.28 m (Roblox default approx.)
end

function TrainPhysics.new(model, config)
local self = setmetatable({}, TrainPhysics)
self.Model = model
self.Config = config
self.Seat = model:WaitForChild("DriverSeat", 1)
self.Throttle = 0
self.Brake = 0
self.Speed = 0
self.TargetSpeed = 0
self.LastPosition = model.PrimaryPart and model.PrimaryPart.Position or Vector3.zero
self.LastUpdate = tick()
self.IsAdvanced = config.IsAdvanced or false
self.SteamState = config.SteamState
self.Identifier = config.Identifier or (model.Name .. "_" .. tostring(#trains + 1))
self.Attachment = Instance.new("Attachment")
self.Attachment.Name = "DownforceAttachment"
self.Attachment.Parent = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
CollectionService:AddTag(model, "DrivableTrain")
trains[self.Identifier] = self
return self
end

function TrainPhysics:SetThrottle(value)
self.Throttle = clamp(value, -1, 1)
end

function TrainPhysics:SetBrake(value)
self.Brake = clamp(value, 0, 1)
end

function TrainPhysics:GetForwardVector()
local primary = self.Model.PrimaryPart or self.Model:FindFirstChildWhichIsA("BasePart")
return primary and primary.CFrame.LookVector or Vector3.new(0, 0, -1)
end

function TrainPhysics:GetVelocity()
local primary = self.Model.PrimaryPart or self.Model:FindFirstChildWhichIsA("BasePart")
return primary and primary.AssemblyLinearVelocity or Vector3.zero
end

function TrainPhysics:ApplyForces(dt)
local primary = self.Model.PrimaryPart or self.Model:FindFirstChildWhichIsA("BasePart")
if not primary then
return
end

local forward = primary.CFrame.LookVector
local velocity = primary.AssemblyLinearVelocity
local speed = velocity:Dot(forward)
local lateral = velocity - forward * speed

local maxSpeed = kmhToStudsPerSecond(self.Config.MaxSpeedKmh or Constants.Train.MaxSpeedKmh)
self.TargetSpeed = self.Throttle * maxSpeed
if self.SteamState then
local warning = self.SteamState.WarningState
if warning == "LowWater" then
self.Throttle = math.min(self.Throttle, 0)
self.Brake = math.max(self.Brake, 0.4)
elseif warning == "SafetyValve" then
self.Throttle = math.clamp(self.Throttle, -0.2, 0.5)
end
end
local desiredAccel = (self.TargetSpeed - speed) * (self.Config.AccelerationRate or Constants.Train.AccelerationRate)
local brakeForce = -math.sign(speed) * self.Brake * (self.Config.BrakeRate or Constants.Train.BrakeRate)
local force = (desiredAccel + brakeForce) * forward

    local bodyForce = self.Force or Instance.new("VectorForce")
    bodyForce.Name = "DriveForce"
    bodyForce.RelativeTo = Enum.ActuatorRelativeTo.World
    bodyForce.Attachment0 = self.Attachment
    bodyForce.Parent = self.Attachment
    bodyForce.Force = force * primary.AssemblyMass
    self.Force = bodyForce

    local downforce = self.Downforce or Instance.new("VectorForce")
    downforce.Name = "Downforce"
    downforce.RelativeTo = Enum.ActuatorRelativeTo.World
    downforce.Attachment0 = self.Attachment
    downforce.Parent = self.Attachment
    local dfMagnitude = (self.Config.DownforceFactor or Constants.Train.DownforceFactor) * (math.abs(speed) + 10)
    downforce.Force = Vector3.new(0, -dfMagnitude * primary.AssemblyMass, 0)
    self.Downforce = downforce

    local lateralForce = self.LateralForce or Instance.new("VectorForce")
    lateralForce.Name = "LateralStabilizer"
    lateralForce.RelativeTo = Enum.ActuatorRelativeTo.World
    lateralForce.Attachment0 = self.Attachment
    lateralForce.Parent = self.Attachment
    lateralForce.Force = -lateral * (self.Config.LateralDamping or Constants.Train.LateralDamping) * primary.AssemblyMass
    self.LateralForce = lateralForce

local lateralMagnitude = lateral.Magnitude
if lateralMagnitude > (self.Config.DerailLateralThreshold or Constants.Train.DerailLateralThreshold) then
self.Throttle *= (self.Config.AutoStabilizeThrottleFactor or Constants.Train.AutoStabilizeThrottleFactor)
self.Brake = math.min(1, self.Brake + 0.2)
end
end

function TrainPhysics:Update(dt)
self:ApplyForces(dt)

local primary = self.Model.PrimaryPart or self.Model:FindFirstChildWhichIsA("BasePart")
if not primary then
return
end

self.Speed = primary.AssemblyLinearVelocity.Magnitude
self.LastPosition = primary.Position
self.LastUpdate = tick()
end

function TrainPhysics:Destroy()
if self.Force then
self.Force:Destroy()
end
if self.Downforce then
self.Downforce:Destroy()
end
if self.LateralForce then
self.LateralForce:Destroy()
end
if self.Attachment then
self.Attachment:Destroy()
end
trains[self.Identifier] = nil
end

RunService.Heartbeat:Connect(function(dt)
for _, train in pairs(trains) do
train:Update(dt)
end
end)

return TrainPhysics
