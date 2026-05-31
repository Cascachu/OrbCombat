# OrbCombat — Full Project Documentation

## Table of Contents
1. [Overview](#overview)
2. [Tech Stack](#tech-stack)
3. [Project Structure](#project-structure)
4. [Screens](#screens)
5. [Orb Types](#orb-types)
6. [Status Effects](#status-effects)
7. [Core Systems](#core-systems)
8. [Autoloads](#autoloads)
9. [UI Components](#ui-components)
10. [External API](#external-api)
11. [Local Storage](#local-storage)
12. [Shop & Hats](#shop--hats)
13. [Android Export](#android-export)

---

## Overview

OrbCombat is a physics-based battle simulator for Android built in Godot 4. Two orbs fight autonomously in a fixed arena, bouncing off walls and each other. Each orb type has unique stats and a special ability. Players bet coins on match outcomes and can purchase cosmetic hats from the shop.

---

## Tech Stack

| Component | Technology |
|---|---|
| Engine | Godot 4 |
| Language | GDScript |
| Platform | Android (APK) |
| Local Storage | Godot FileAccess (`user://stats.txt`) |
| External API | randomuser.me REST API |
| Version Control | Git / GitHub |

---

## Project Structure

```
res://
├── Fighters/
│   ├── ball.gd              # Base orb script
│   ├── ball.tscn            # Base orb scene
│   └── orbs/
│       ├── fire_orb.gd / fire_orb.tscn
│       ├── ice_orb.gd / ice_orb.tscn
│       ├── slime_orb.gd / slime_orb.tscn
│       ├── sword_orb.gd / sword_orb.tscn
│       ├── boom_ball.gd / boom_ball.tscn
│       └── puffer_orb.gd / puffer_orb.tscn
├── Conditions/
│   ├── burn.gd              # Burn status effect
│   └── freeze.gd            # Freeze status effect
├── Effects/
│   ├── explosion.tscn       # Boom ball explosion visual
│   └── death_particle.tscn  # Death particle effect
├── Hats/
│   └── (hat textures)
├── Shop/
│   ├── shop.tscn / shop.gd
│   └── hat_panel.tscn / hat_panel.gd
├── UI/
│   └── orb_card.tscn        # Per-orb stat card used in side panels
├── Abilities/
│   └── weapon.gd            # Sword orb weapon logic
├── game_state.gd            # Autoload: cross-scene data
├── player_stats.gd          # Autoload: persistent player stats
├── hats.gd                  # Autoload: hat definitions
├── main_menu.tscn
├── fighter_select.tscn
└── game.tscn
```

---

## Screens

### 1. Main Menu (`main_menu.tscn`)
Entry point of the application. Shows the game title and a Play button that navigates to Fighter Select.

---

### 2. Fighter Select (`fighter_select.tscn`)
Lets the player configure the match before fighting.

**Features:**
- Two `OptionButton` dropdowns to select orb types
- Prevents selecting the same orb twice (shows `AcceptDialog` warning)
- `OptionButton` to choose which fighter to bet on
- `SpinBox` to set bet amount (max value capped to current coin balance, set in `_ready`)
- Shop button to navigate to the shop
- Stats bar showing current coins, wins and losses

---

### 3. Shop (`shop.tscn`)
Scrollable list of purchasable hats.

**Features:**
- Dynamically generates one `hat_panel` per hat defined in `Hats.HATS`
- Each panel shows preview texture, name, price and a single action button
- Action button cycles: **Buy** → **Equip** → **Unequip**
- Purchasing deducts coins from `PlayerStats`
- Stats bar showing current coins, wins and losses
- Reset stats button with `ConfirmationDialog`

---

### 4. Game (`game.tscn`)
Main battle screen.

**Scene structure:**
```
Game (Control)
├── WorldBorders (Node2D) — arena node, centered on screen at runtime
│   ├── LeftPanel / RightPanel — orb stat panels (children of arena)
│   └── 4x StaticBody2D — collision walls
├── Fighters (Node2D) — orbs spawned here
├── CanvasLayer
│   ├── GameOverPanel
│   └── StatsBar
├── Background
└── WorldEnvironment
```

**Key responsibilities:**
- Centers arena on screen: `$WorldBorders.position = (screen_size - arena_size) / 2`
- Instantiates selected fighters from `GameState`
- Assigns teams (`"one"` / `"two"`) and names to fighters
- Connects `name_loaded` signal to store fighter names once API responds
- Applies equipped hat texture to the bet-on fighter's `Hat` sprite node
- Detects game over each frame by checking which teams have alive balls
- Resolves bet and shows game over panel

---

### 5. Game Over Panel
Shown when one or both teams have no alive orbs. Displays result, resolves bet, and offers Play Again.

---

## Orb Types

All orbs extend `ball.gd` and override `use_ability(target)`.

| Orb | Health | Damage | Size | Speed | Special Ability |
|-----|--------|--------|------|-------|-----------------|
| Ball | 100 | 10 | 1.0 | 600 | None |
| Fire Orb | 80 | 0 | 0.8 | 600 | Stacking burn on hit |
| Ice Orb | 100 | 6 | 1.1 | 600 | Freezes target for 3 ticks |
| Slime Orb | 100 | 8 | 1.2 | 450 | Splits into 2 on death (max 3 generations) |
| Sword Orb | 120 | 5 | 1.0 | 600 | Orbiting blade deals 15 dmg with knockback |
| Boom Ball | 120 | 8 | 1.1 | 600 | Explodes every 10 ticks, 25 dmg in radius |
| Puffer Orb | 100 | 5/15 | 0.6/2.0 | 600 | Puffs up every 5s: size x2, damage x3 |

---

### Fire Orb
Injects a `Burn` node onto the target on every collision hit. Each subsequent hit adds a stack. Does no direct collision damage (`damage = 0`).

### Ice Orb
Injects a `Freeze` node onto the target. Resets duration to 3 ticks if already frozen. Movement feels slippery due to velocity lerping. Takes 2 damage on every bounce (walls and orbs).

### Slime Orb
Overrides `take_damage` with an `is_dying` guard to prevent double-death. On death, spawns 2 children via `duplicate()` with incremented `generation`. Children inherit the parent's name with a Roman numeral suffix and have `skip_name_fetch = true`.

**Generations:**
| Gen | Health | Damage | Size | Speed |
|-----|--------|--------|------|-------|
| 0 | 100 | 8 | 1.2 | 450 |
| 1 | 50 | 4 | 1.0 | 600 |
| 2 | 25 | 2 | 0.6 | 750 |

### Sword Orb
A `Pivot` node rotates every `_process` tick. The `Weapon` (Area2D) is offset from center to orbit the orb. A single boolean cooldown prevents repeat hits. Sword is hidden and disabled while the orb is frozen.

### Boom Ball
Counts ticks (1 per second) in `_physics_process`. On tick 10 spawns `explosion.tscn`, passes `self` as `source` to prevent self-damage, then resets. Explosion is an `Area2D` that implodes visually (starts full size, shrinks to 0.5) and damages all balls inside except the source on spawn.

### Puffer Orb
Auto-cycles puff state. Exports `normal_texture` and `puff_texture` swapped on state change. Ability only triggers when not puffed and not on cooldown.

---

## Status Effects

Status effects are self-contained `Node` scripts injected as children of the target at runtime.

### Burn (`burn.gd`)
| Property | Value |
|---|---|
| Tick rate | 1 second |
| Damage per tick | Equal to stack count |
| Stacking | Yes — each Fire Orb hit adds 1 stack |
| Cleanup | Freed when parent dies |

Uses `parent.take_damage(stacks, parent.name)` so damage goes through the standard health system.

### Freeze (`freeze.gd`)
| Property | Value |
|---|---|
| Duration | 3 ticks (1 second each) |
| Effect | `speed = 0`, `velocity = Vector2.ZERO` |
| Sword interaction | Sword Orb weapon hidden and disabled |
| Cleanup | Restores original speed and velocity, then `queue_free()` |

---

## Core Systems

### Collision System (`ball.gd`)

Uses `static var handled_this_frame` — a list shared across all ball instances, cleared each physics frame. Each collision generates a sorted ID pair from both balls' instance IDs so A→B and B→A map to the same entry. The first ball to detect a collision handles damage and abilities for both sides and sets both invincible, preventing double-processing.

```
Collision detected
→ Generate sorted collision ID
→ If ID not in handled_this_frame:
    → Deal damage (both sides)
    → Apply abilities (both sides)
    → Set both invincible
    → Add ID to handled_this_frame
→ Calculate push direction + random angle
→ Set velocity
```

Frozen orbs do not deal damage (checked via `get_node_or_null("Freeze")` on the collider before dealing damage).

### Steering
After every wall bounce, velocity is nudged toward the nearest enemy:
```gdscript
velocity = velocity.lerp(direction_to_enemy * speed, STEERING_STRENGTH)
```
This encourages orbs to eventually find each other without making movement feel scripted.

### Name Fetch
Each orb makes an async `HTTPRequest` in `_ready` to randomuser.me. On success, sets `name` to the returned first name and emits `name_loaded`. Skipped if `skip_name_fetch = true` (used by slime children).

### Death
Spawns `deathParticle` at world position, then `queue_free()`. Death particles are added to `get_tree().current_scene` so they persist briefly after the orb is freed.

---

## Autoloads

### `game_state.gd`
| Variable | Type | Description |
|---|---|---|
| `fighter_one` | String | Scene path of fighter 1 |
| `fighter_two` | String | Scene path of fighter 2 |
| `bet_on` | String | `"one"` or `"two"` |
| `bet_amount` | int | Coins wagered |

### `player_stats.gd`
| Variable | Default | Description |
|---|---|---|
| `coins` | 100 | Current balance |
| `wins` | 0 | Total wins |
| `losses` | 0 | Total losses |
| `owned_hats` | `[]` | Purchased hat IDs |
| `equipped_hat` | `""` | Currently equipped hat |

| Method | Effect |
|---|---|
| `add_win(bet)` | `wins += 1`, `coins += bet * 2` |
| `add_loss(bet)` | `losses += 1`, `coins -= bet` |
| `add_draw(bet)` | `coins += bet` (refund) |
| `buy_hat(id, price)` | Deducts price, adds to owned |
| `equip_hat(id)` | Sets equipped (pass `""` to unequip) |
| `reset_stats()` | Resets everything to defaults |

### `hats.gd`
Dictionary of all available hats. Adding a new hat only requires a new entry here.

```gdscript
const HATS = {
    "tophat": { "name": "Top Hat", "price": 100, "texture": "res://Hats/tophat.png" },
    "crown":  { "name": "Crown",   "price": 250, "texture": "res://Hats/crown.png"  },
    "cap":    { "name": "Cap",     "price": 50,  "texture": "res://Hats/cap.png"    },
}
```

---

## UI Components

### Stats Bar (`stats_bar.gd`)
Top bar showing coins, wins and losses. Reads `PlayerStats` every frame. Uses cached `has_node` checks so it works on any panel with any subset of the three labels.

### Side Panels (`stats_panel.gd`)
One panel per team alongside the arena. Extends `VBoxContainer`. Dynamically creates one `orb_card` per alive orb. Cards only rebuilt when count changes; values update every frame.

### Orb Card (`orb_card.tscn`)
Shows a single orb's name, HP, damage, speed and sprite preview. All values set by `stats_panel.gd`.

### Hat Panel (`hat_panel.gd`)
Single action button handles all states: Buy / Equip / Unequip. Refreshes all sibling panels after equip/unequip to keep button states in sync.

### OrbUI (`orb_ui.gd`)
Child of each orb scene. Shows name label and health progress bar below the orb. Counteracts parent scale so UI stays fixed pixel size regardless of orb scale. Positions itself below the orb proportionally to orb size.

---

## External API

**Provider:** [randomuser.me](https://randomuser.me)  
**Purpose:** Assign random first names to orbs at spawn  
**Cost:** Free, no API key required

**Endpoint:**
```
GET https://randomuser.me/api/?inc=name&noinfo&nat=US,GB,AU,CA,PL,DE,FR,SE,CZ,CH
```

**Nationalities:** USA, UK, Australia, Canada, Poland, Germany, France, Sweden, Czech Republic, Switzerland — all Latin alphabet to avoid RTL text issues.

**Flow:**
1. Orb spawns → `fetch_name()` called in `_ready`
2. `HTTPRequest` node created, added as child, request fired
3. On response → first name extracted → `name` set → `name_loaded` emitted
4. `game.gd` stores the name via connected lambda for use in game over screen

**Slime children** skip the fetch and use: `"ParentName II"`, `"ParentName III"`

---

## Local Storage

File: `user://stats.txt` (Android: app's private internal storage)

**Format (one value per line):**
```
100            ← coins
6              ← wins
9              ← losses
tophat,cap     ← owned hats (comma separated, empty string if none)
tophat         ← equipped hat (empty string if none)
```

Created automatically on first save. Loaded in `player_stats.gd _ready()`.

---

## Shop & Hats

Hats are cosmetic items purchased with coins. The equipped hat appears on the fighter the player bet on. Applied by setting the texture of a `Sprite2D` node named `Hat` present in every orb scene (no texture by default).

Coins economy:
| Event | Coins |
|---|---|
| Starting balance | 100 |
| Win | +bet × 2 |
| Loss | -bet |
| Draw | +bet (refund) |

---

## Android Export

| Setting | Value |
|---|---|
| Export format | APK |
| Min SDK | 24 |
| Target SDK | 35 |
| Architecture | arm64-v8a |
| Viewport | 480 × 854 |
| Stretch Mode | canvas_items |
| Stretch Aspect | expand |
| Orientation | Portrait |

**Signing:** Release APK signed with a keystore generated via `keytool`. Keystore is not committed to version control.

**Distribution:** Sideloaded APK. Users must enable "Install from unknown sources" in Android settings.
