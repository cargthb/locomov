local Constants = {}

Constants.GAME_NAME = "TESTLOCOMOTIVA"
Constants.CREATOR = "C.RELLA"

Constants.Player = {
WalkSpeed = 12, -- km/h
SprintSpeed = 22,
CameraSprintFOV = 80,
DefaultFOV = 70,
}

Constants.Track = {
PracticeLaneCount = 10,
PracticeLaneLength = 300,
PracticeLaneSpacing = 20,
PracticeLaneWidth = 8,
LoopRadius = 60,
LoopStraightLength = 80,
RailHeight = 1,
RailWidth = 0.4,
SleeperSpacing = 5,
}

Constants.Train = {
WheelRadius = 2,
MaxSpeedKmh = 75,
AccelerationRate = 18,
BrakeRate = 40,
DownforceFactor = 12,
LateralDamping = 4,
DerailLateralThreshold = 1.6,
AutoStabilizeThrottleFactor = 0.7,
}

Constants.Steam = {
CoalCapacity = 100,
WaterCapacity = 100,
PressureSafeMax = 220,
PressureMin = 40,
FireTemperatureMax = 900,
CoalBurnRate = 0.15,
WaterUseRate = 0.12,
InjectorRate = 0.4,
PressureBuildRate = 35,
PressureUseRate = 45,
}

return Constants
