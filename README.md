# TESTLOCOMOTIVA by C.RELLA

This repository contains a Rojo-compatible Roblox experience that builds the TESTLOCOMOTIVA sandbox yard. The project delivers:

- A minimal beige start screen with a single Start button and credit to C.RELLA.
- A Little Book help manual that opens on spawn and is toggleable with **B** / **D-Pad Up**.
- A practice yard featuring ten empty, evenly spaced track lanes for experimentation.
- A static showcase with low, medium, and high detail locomotive displays.
- Two drivable steam locomotives on a closed loop, each with advanced steam-era simulation (coal, water, pressure, fire temperature).
- A shared speedometer HUD that tracks avatar and vehicle speeds in km/h, plus an in-cab steam status panel.

## Project Structure

```
default.project.json   # Rojo tree mapping
src/
  Workspace/           # Runtime yard built by server scripts
  StarterGui/          # Start screen, speedometer, Little Book UI scripts
  StarterPlayer/
    StarterPlayerScripts/
      MovementController.client.lua
      TrainControls.client.lua
  ServerScriptService/
      GameState.server.lua
      YardBuilder.server.lua
      TrainManager.server.lua
  ReplicatedStorage/
      GameSignals/init.lua
      TrainSystems/
        Constants.lua
        TrainFactory.lua
        SteamSimulation.lua
        TrainPhysics.lua
```

## Getting Started

1. Install [Rojo](https://rojo.space/).
2. Open Roblox Studio and create an empty place.
3. Run `rojo serve` inside the repository and connect from Studio with the Rojo plugin.
4. Play the experience to explore the yard, read the Little Book, and test both locomotives.

### Controls

- **Movement:** WASD / Left Stick
- **Sprint:** Shift / Button B
- **Interact (enter cab):** E / Button X
- **Exit cab:** Q / Circle
- **Throttle:** W / S or RT / LT (uses step-based input)
- **Brake:** Space / LB
- **Whistle:** H / RB
- **Stoke Fire:** F / Button X
- **Toggle Injector:** R / Button Y
- **Camera Toggle:** C / Right Stick Click
- **Little Book:** B / D-Pad Up

The speedometer and in-cab HUD display current km/h and steam system vitals (coal %, water %, pressure, fire temperature, injector state, warnings).

## Steam Management Summary

Keep the fire stoked, add water with the injector, and monitor pressure. Safety valves relieve overpressure, while critically low water locks the throttle until the boiler is refilled.

Enjoy building and testing in TESTLOCOMOTIVA! 
