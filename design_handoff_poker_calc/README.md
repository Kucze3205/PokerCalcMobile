# Handoff: Poker Calc — Mobile UI

## Overview
A mobile poker probability calculator UI. The user selects their hand cards and community cards; the app displays a win probability ring. Card selection uses a two-step gesture: tap a card slot → touch & hold a suit button → slide to a rank → release to confirm. The interaction mirrors the iOS/Android keyboard long-press extra-character picker.

## About the Design Files
The files in this bundle are **high-fidelity HTML prototypes** — not production code to ship. They demonstrate exact colors, typography, spacing, animations, and interaction behavior. Your task is to **recreate this UI in your target environment** (React Native, SwiftUI, Kotlin, Flutter, etc.) using its established patterns and libraries, matching the visual and interaction fidelity shown here.

Open `Poker Calc Prototype.html` in a browser to see and interact with the full prototype. Use the **Tweaks** panel (toolbar icon) to switch themes, card styles, and see design variations.

## Fidelity
**High-fidelity.** Pixel-accurate colors, spacing, typography and animations. Recreate the UI to match exactly, using your codebase's design system where it overlaps.

---

## Screens / Views

### 1. Main Screen (Idle)
The full-screen view. Everything is visible at once — no separate screens.

**Layout:** Vertical flex column, full viewport.
- Top bar (fixed, 52px tall)
- Scroll area (flex: 1, overflow scroll)
  - Your Hand card (112px tall)
  - Community Cards card (88px tall)
  - Hint text
- Bottom sheet (always visible, height animates)

---

### 2. Top Bar
**Position:** Top of screen, `padding: 10px 14px 8px`  
**Layout:** `display: flex, align-items: center, gap: 8px`

| Element | Details |
|---|---|
| App icon | 32×32px, `border-radius: 9px`, background `#1a4a30`, border `1.5px solid #2ecc71`, emoji 🎲 |
| Title "Poker Calc" | `font: Space Mono 700 12px`, color `#b8d8c4` |
| Players pill | `border: 1.5px solid #2ecc71`, `border-radius: 99px`, `padding: 3px 10px`, color `#2ecc71`, bg `#1a4a30`, `font-size: 10px`. Tap cycles 2–9 players. |
| Reset button | 30×30px, `border-radius: 8px`, border `1.5px solid #922`, color `#c0392b`, icon `↺` |

---

### 3. Your Hand Section
**Background:** `#0f2019` · **Border-radius:** `12px` · **Padding:** `12px`

**Layout:** Row — left: two card slots stacked with number labels; right: probability ring (centered, flex: 1).

#### Card Slots (hand)
- Size: **46×62px**, `border-radius: 7px`
- Empty state: `border: 2px dashed #3d6b52`, background transparent, `+` icon `#3d6b52`
- Active (being filled): `border: 2px solid #2ecc71`, bg `#1a4a30`, `box-shadow: 0 0 12px #2ecc7166`
- Filled / Ghost style: `border: 2px solid #2ecc71`, bg `#1a3028`, rank in `#2ecc71 Space Mono 700 13px`, suit symbol `#b8d8c4 14px`
- Filled / Physical style: white `#f5f0e8` background, border `1px solid #ccc`, rank in `#111 700 12px`, suit in `#222 16px`, `box-shadow: 2px 3px 10px #00000077`

#### Probability Ring
- SVG, 72×72px
- Background circle: `stroke #1a3028`, `stroke-width 6`
- Progress arc: `stroke #2ecc71`, `stroke-width 6`, `stroke-linecap round`, rotated -90°, animates `stroke-dasharray` over 0.5s
- Center label: `Space Mono 700 12px #2ecc71` (shows `--` when no cards selected)
- Below: `WIN %` label, `8px #3d6b52`, `letter-spacing: 1`

---

### 4. Community Cards Section
**Background:** `#0f2019` · **Border-radius:** `12px` · **Padding:** `12px`

5 card slots in a row, `gap: 6px`, centered.
- Size: **30×42px**, `border-radius: 7px`
- Same empty/active/filled states as hand cards, just smaller

---

### 5. Bottom Sheet
**Background:** `#070e0a` · **Border-radius:** `16px 16px 0 0` · **Border:** `1px solid #1a3028 (top + sides only)`  
Height animates between 3 states:
| State | Height | Content |
|---|---|---|
| Idle | 130px | Drag handle + dimmed suit buttons + hint label |
| Suit selection active | 200px | Drag handle + context label + 4 suit buttons (2×2 grid) |
| Rank picking | 390px | Drag handle + suit indicator + rank keypad |

**Drag handle:** 36×3px, `border-radius: 99px`, `background #1a3028`, centered, `margin-bottom: 10px`

**Height transition:** `height 0.25s cubic-bezier(0.4, 0, 0.2, 1)`

#### Suit Buttons (2×2 grid, `gap: 8px`)
- **Enabled:** `background #0f2019`, `border: 1.5px solid #1a3028`, `border-radius: 10px`, `padding: 14px 0`
- **Disabled (no slot selected):** same but `opacity: 0.35`
- **Pressed:** `background #1a4a30`, `border-color #2ecc71`, `box-shadow: 0 0 12px #2ecc7155`
- Suit symbol: `24px color #b8d8c4`
- Suit name (Kier/Karo/Trefl/Pik): `9px #3d6b52 letter-spacing: 0.5`
- Suits: ♥ Kier, ♦ Karo, ♣ Trefl, ♠ Pik

---

## Rank Keypad
Appears in the bottom sheet after a suit is touched. Layout:

```
[ A ]  [ J ]  [ Q ]  [ K ]     ← 4 columns, height 44px each
[ 2 ]  [ 3 ]  [ 4 ]            ← 3 columns
[ 5 ]  [ 6 ]  [ 7 ]
[ 8 ]  [ 9 ]  [ 10 ]
```

- Cell: `height 44px`, `border-radius 9px`, `background #0f2019`, `border: 1.5px solid #1a3028`
- Font: `Syne 700 17px` (13px for "10"), color `#b8d8c4`
- Hovered/active cell: `background #2ecc71`, `color #000`, `transform: scale(1.08)`, `box-shadow: 0 0 14px #2ecc7177`
- Transition: `transform 0.08s, background 0.08s`
- **IMPORTANT:** cells must have `pointer-events: none` and be identified by `data-rank` attribute so `document.elementFromPoint` can find them during the slide gesture

---

## Interactions & Behavior

### Core Gesture — Card Selection (KEY FEATURE)
This is the signature interaction. It is a **single continuous gesture**:

1. User taps a card slot → slot highlights, bottom sheet slides up showing suit buttons
2. User presses & holds a suit button → `pointerdown` fires immediately → sheet animates to rank keypad height
3. **Pointer capture** is set on the suit button element (`element.setPointerCapture(pointerId)`)
4. While finger is held down, user slides over the keypad → `document.elementFromPoint(x, y)` reads which `[data-rank]` cell is under the finger → that cell highlights
5. User releases finger on a cell → rank is confirmed, card slot is filled, sheet collapses
6. User releases finger on empty area → gesture is cancelled, returns to suit selection

**No lifting the finger between suit and rank selection.** One unbroken touch gesture.

### Hint Text
- Idle: "TAP A CARD SLOT TO SELECT" (muted color)
- Slot selected: "TOUCH & HOLD A SUIT BELOW" (accent color, `pulse` animation)
- Rank picking: "SLIDE TO A RANK → RELEASE" (accent color, static)

### Win Probability
- Appears after both hand cards are filled
- Simulated value 35–75% (replace with real poker equity calculator)
- Ring arc animates via `stroke-dasharray` transition

### Players pill
Tap to cycle 2 → 3 → … → 9 → 2

### Reset button
Clears all cards, probability, and resets sheet to idle

---

## Design Tokens (Felt Theme — default)

```
--bg:           #0b1812   (page background)
--card-bg:      #0f2019   (section cards)
--dim:          #1a3028   (borders, inactive elements)
--accent:       #2ecc71   (primary green)
--accent-dim:   #1a4a30   (pressed states, active backgrounds)
--muted:        #3d6b52   (secondary text, icons)
--text:         #b8d8c4   (primary text)
--sheet-bg:     #070e0a   (bottom sheet)
--status-bg:    #050d08   (status/nav bar)
--shell-border: #2a2a2a   (phone frame)
```

### Typography
- **Primary font:** Space Mono (monospace) — weights 400, 700
- **Keypad font:** Syne — weight 700, 800
- Minimum text size: 8px (labels), 9px (buttons), 12px (card ranks)

### Spacing
- Section padding: 12px
- Gap between sections: 10px
- Card slot gap: 8px (hand), 6px (community)
- Suit button gap: 8px
- Keypad cell gap: 6px
- Sheet padding: 8px 12px 16px

### Border Radii
- Sections: 12px
- Card slots: 7px
- Suit buttons: 10px
- Keypad cells: 9px
- Probability ring nodes: 50%
- Bottom sheet: 16px 16px 0 0

### Animations
- Sheet height: `height 0.25s cubic-bezier(0.4, 0, 0.2, 1)`
- Hint text pulse: `opacity 0→1→0`, 1.2s infinite
- Rank cell hover: `transform + background 0.08s`
- Prob ring: `stroke-dasharray 0.5s`
- `popIn` keyframe: `scale(0.6) opacity(0)` → `scale(1) opacity(1)`, 0.12s

---

## Theme Variants
Three themes are implemented (toggle in Tweaks panel):

| Token | Felt (default) | Neon | Chalk |
|---|---|---|---|
| accent | `#2ecc71` | `#00f5c4` | `#f0a500` |
| bg | `#0b1812` | `#08081a` | `#161620` |
| font | Space Mono | Syne | Space Mono |

---

## Files in This Bundle

| File | Purpose |
|---|---|
| `Poker Calc Prototype.html` | Full interactive prototype — open in any browser |
| `Rank Picker Explorations.html` | 6 rank picker design alternatives (canvas view) |
| `tweaks-panel.jsx` | Tweaks UI helper (prototype-only, not for production) |
| `README.md` | This document |

---

## Implementation Notes

- The pointer-capture gesture requires the Web Pointer Events API (available in all modern mobile browsers, React Native via Pressable + PanResponder or Gesture Handler, iOS via UILongPressGestureRecognizer + UIPanGestureRecognizer chained)
- `document.elementFromPoint` has no native equivalent in React Native — use layout measurements + gesture coordinates instead
- Win probability should use a real poker equity engine (e.g. PokerSolver, PokerHandEvaluator, or a backend API)
- The probability ring is decorative/simulated in the prototype — real implementation needs Monte Carlo simulation or lookup tables
