# Smart Parking Controller with FSM Interlocks (VHDL)

An automated parking barrier gate access controller modeled in VHDL. Utilizes a deterministic Moore Finite State Machine (FSM) to supervise vehicle sensing, 4-bit passcode authentication, timeout countdowns, and visual access indicators.

## Architecture & Features
- **FSM State Controller:**
  - `idle`: Waits for arrival at entrance sensor.
  - `waitting`: Prompts for credential input with hardware countdown timeout.
  - `correct_password`: Validates passcode (`0111`), opens barrier gate (`green_light = 1`), and waits for inner presence sensor confirmation.
  - `wrong_password`: Denies entry (`red_light = 1`), allows retry window before timeout lockdown.
  - `stop`: Cycles system back to initial baseline safely.
- **Hardware Timeout Management:** 33-bit hardware counter provides non-blocking timeout detection to prevent gate lockouts.
- **Sensory Interlocking:** Dual-sensor feedback (`outside_sensor` and `inside_sensor`) ensures barrier closes only after the vehicle has completely cleared the gate boundary.

## Directory Structure
```
├── car_parking_sys.vhd   # Main FSM controller in VHDL
└── README.md             # Architecture documentation
```
