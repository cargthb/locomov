local RunService = game:GetService("RunService")

local Constants = require(script.Parent.Constants)

local SteamSimulation = {}
SteamSimulation.__index = SteamSimulation

local activeSimulations = {}

local function clamp(value, min, max)
return math.max(min, math.min(max, value))
end

function SteamSimulation.new(trainId, overrides)
overrides = overrides or {}
local self = setmetatable({}, SteamSimulation)
self.Identifier = trainId
self.Coal = overrides.Coal or Constants.Steam.CoalCapacity
self.Water = overrides.Water or Constants.Steam.WaterCapacity
self.Pressure = overrides.Pressure or Constants.Steam.PressureMin
self.FireTemperature = overrides.FireTemperature or Constants.Steam.FireTemperatureMax * 0.35
self.Maintenance = overrides.Maintenance or 100
self.InjectorOn = false
self.StokerBoost = 0
self.WarningState = nil
activeSimulations[trainId] = self
return self
end

function SteamSimulation:ConsumeCoal(dt, throttle)
local burnRate = Constants.Steam.CoalBurnRate * (0.5 + math.abs(throttle)) + self.StokerBoost
local consumption = burnRate * dt
if self.Coal <= 0 then
self.Coal = 0
self.FireTemperature = math.max(100, self.FireTemperature - 20 * dt)
return
end
self.Coal = math.max(0, self.Coal - consumption)
self.FireTemperature = clamp(self.FireTemperature + 40 * dt, 100, Constants.Steam.FireTemperatureMax)
self.StokerBoost = math.max(0, self.StokerBoost - 0.2 * dt)
end

function SteamSimulation:ConsumeWater(dt, throttle)
local baseUse = Constants.Steam.WaterUseRate * (0.4 + math.abs(throttle))
self.Water = clamp(self.Water - baseUse * dt, 0, Constants.Steam.WaterCapacity)
if self.InjectorOn then
self.Water = clamp(self.Water + Constants.Steam.InjectorRate * dt, 0, Constants.Steam.WaterCapacity)
self.Pressure = math.max(Constants.Steam.PressureMin, self.Pressure - 10 * dt)
end
end

function SteamSimulation:UpdatePressure(dt, throttle)
local fireFactor = self.FireTemperature / Constants.Steam.FireTemperatureMax
local pressureGain = Constants.Steam.PressureBuildRate * fireFactor * dt
local pressureUse = Constants.Steam.PressureUseRate * math.abs(throttle) * dt
self.Pressure = clamp(self.Pressure + pressureGain - pressureUse, 0, Constants.Steam.PressureSafeMax + 40)
if self.Pressure > Constants.Steam.PressureSafeMax then
self.WarningState = "SafetyValve"
self.Pressure = self.Pressure - 25 * dt
elseif self.Water <= Constants.Steam.WaterCapacity * 0.1 then
self.WarningState = "LowWater"
elseif self.Coal <= 5 then
self.WarningState = "LowCoal"
else
self.WarningState = nil
end
end

function SteamSimulation:Stoke()
self.StokerBoost = math.min(8, self.StokerBoost + 2)
self.Coal = clamp(self.Coal + 2, 0, Constants.Steam.CoalCapacity)
end

function SteamSimulation:ToggleInjector(state)
if state == nil then
self.InjectorOn = not self.InjectorOn
else
self.InjectorOn = state
end
end

function SteamSimulation:Update(dt, throttle)
self:ConsumeCoal(dt, throttle)
self:ConsumeWater(dt, throttle)
self:UpdatePressure(dt, throttle)
end

function SteamSimulation:GetHUD()
return {
Coal = self.Coal,
Water = self.Water,
Pressure = self.Pressure,
FireTemperature = self.FireTemperature,
InjectorOn = self.InjectorOn,
Warning = self.WarningState,
}
end

RunService.Heartbeat:Connect(function(dt)
for _, sim in pairs(activeSimulations) do
local train = sim.Train
if train then
sim:Update(dt, train.Throttle)
end
end
end)

return SteamSimulation
