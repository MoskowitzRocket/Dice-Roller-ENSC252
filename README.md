# 🎲 Dice Roller Project

**Course:** ENSC 252 – Digital Logic Systems  
**Project Type:** Bonus Project  
**Group:** Bonus Project Group 46  

**Team Members:**
- Veronica Young – 301596679  
- Edward Cao – 301594924  
- Kale Moskowitz – 301588993  

---

## 🔧 Project Overview

This project simulates a digital dice roller on an FPGA, allowing the user to:
- Choose between 1, 2, or 3 dice
- Select from standard RPG dice (D4, D6, D8, D10, D12, D20)
- Roll dice using a pushbutton input
- Stop the dice mid-roll (soft reset)
- Reset all dice to a value of 1 (hard reset)

All controls are implemented using physical **switches and keys** on the FPGA development board (DE1-SOC).

---

## 💡 Why Our Implementation Stands Out

- **Fully Configurable:** Dice count and number of sides are configurable at runtime via switches.
- **Dual Reset Mechanism:** Supports both:
  - **Soft reset** (stop the roll, retain value)
  - **Hard reset** (reset all dice to 1)
- **Realistic Rolling Simulation:** Uses a pseudo-random LFSR-based generator with variable roll duration for realism.

---

## 🕹️ Controls

### Dice Side Selection (SW[9:4]):
| Switch Input | Max Dice Sides |
|--------------|----------------|
| `100000`     | 20             |
| `010000`     | 12             |
| `001000`     | 10             |
| `000100`     | 8              |
| `000010`     | 6              |
| `000001`     | 4              |
| Invalid combo| 0              |

### Dice Count Selection (SW[3:1]):
| Switch Input | Number of Dice |
|--------------|----------------|
| `100`        | 3              |
| `010`        | 2              |
| `001`        | 1              |
| Invalid combo| 0              |

### Key Inputs:
- `KEY(0)` → Start/roll dice
- `KEY(1)` → Stop roll (soft reset)
- `KEY(2)` → Reset all dice to 1 (hard reset)

---

## 📁 File Structure

### `TestDice.vhd` – (Edward & Kale)
Top-level module responsible for:
- Integrating all components
- Managing user inputs/outputs (switches, keys, LEDs, HEX displays)
- Handling dice roll control logic (start, stop, reset)

### `DiceRoller.vhd` – (Kale)
Handles rolling logic for each die:
- Implements an LFSR-based random number generator
- Supports a finite state machine for roll animation
- Converts results to 7-segment display format
- Notifies when configuration is allowed

### `NumDice.vhd`
Translates dice count switch input into an integer (1–3).

### `Debouncer.vhd`
Cleans switch/key inputs to avoid glitches caused by mechanical bounce.

### `PreScale.vhd`
Divides the clock frequency to a suitable rate for dice roll animation.

---

## 🔢 Output

Each die result is displayed using **two 7-segment HEX displays**, capable of showing values up to 20. Only the required number of displays are active based on dice count.

| Dice Count | HEX Displays Used |
|------------|-------------------|
| 1          | HEX0, HEX1        |
| 2          | HEX0–HEX3         |
| 3          | HEX0–HEX5         |

---

## 📸 Demo

Photos of 1, 2, and 3 dice rolls with various die sizes will be included here:

> *(Insert images of output here for documentation purposes)*

---

## 🔄 Randomization Notes

- LFSR seeds are unique for each `DiceRoller` instance to avoid identical rolls
- Roll duration is randomized between 50–150 clock ticks for a more natural feel

---

## 🧠 Concepts Used

- Finite State Machines (FSM)
- LFSR-based pseudo-random number generation
- Modular VHDL design
- Debouncing & input filtering
- Clock prescaling and signal synchronization
- Multi-digit 7-segment display handling

---

## 📜 License

This project is for educational purposes as part of SFU's ENSC 252 course.

---

