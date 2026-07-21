# VisualizerInstruments

Custom Instruments packages for observing LLM systems on Apple platforms,
paired with two macOS SwiftUI apps that act as test harnesses.

## Packages

| Package                       | Trace Template          | Source                                  | Companion App |
| ----------------------------- | ----------------------- | --------------------------------------- | ------------- |
| **LLM Observation**           | `LLM Observation`       | `VisualizerInstruments.instrpkg`        | `Sample`      |
| **Railtracks Instrumentation**             | `Railtracks Instrumentation` | `RailtracksInstrumentation/RailtracksInstrumentation.instrpkg` | `JSONTools` |

## Requirements

- macOS 26.2+
- Xcode 26.3+

## Structure

```
VisualizerInstruments/
├── VisualizerInstruments.instrpkg   # LLM Observation package
└── LLM Observation.tracetemplate

RailtracksInstrumentation/
├── RailtracksInstrumentation.instrpkg   # Railtracks Instrumentation package
└── Railtracks Instrumentation.tracetemplate

Observability/                       # Shared os_signpost helpers
Sample/                              # SwiftUI harness for LLM Observation
JSONTools/                           # SwiftUI harness for Railtracks Instrumentation
resources/                           # Sample RTSFlowGraph JSON inputs
```

---

## Installing the Instruments packages

An `.instrpkg` is **source** — Instruments can't open it directly (double-
clicking it errors with *"cannot open files in the Instruments Package
Definition format"*). Building the target compiles it into an **`.instrdst`**
bundle, and that bundle is what Instruments loads.

### Build the `.instrdst`

The proper way to produce a distributable package is to **archive** the scheme:
**Product → Archive** (scheme **RailtracksInstrumentation** or
**VisualizerInstruments**). The archive contains the bundle at
`Products/Library/Instruments/Packages/RailtracksInstrumentation.instrdst` — the
canonical install location. Open **Window → Organizer**, select the archive, and
**Show in Finder → Show Package Contents** to retrieve the `.instrdst`.

From the command line:

```bash
xcodebuild -project VisualizerInstruments.xcodeproj \
           -scheme RailtracksInstrumentation \
           -destination 'generic/platform=macOS' \
           -archivePath build/RailtracksInstrumentation.xcarchive archive
# → build/RailtracksInstrumentation.xcarchive/Products/Library/Instruments/Packages/RailtracksInstrumentation.instrdst
```

> A plain build (`⌘B`) also emits an `.instrdst` into the build products folder
> (`Show Build Folder in Finder → Products/Debug/`). That's fine for quick local
> testing, but archiving is the clean, exportable artifact for distribution.

### Install it

Copy the `.instrdst` into your Instruments packages folder and relaunch:

```bash
cp -R ".../RailtracksInstrumentation.instrdst" \
      "$HOME/Library/Application Support/Instruments/Packages/"
osascript -e 'quit app "Instruments"'   # relaunch so it rescans
open -a Instruments
```

### Distribute to someone else

Ship the built **`.instrdst`** (not the `.instrpkg`) plus the matching
`.tracetemplate`. The recipient copies the `.instrdst` into their own
`~/Library/Application Support/Instruments/Packages/` and relaunches
Instruments. They need Instruments installed (it ships with Xcode); no source or
Xcode project is required on their side.

---

## Railtracks Instrumentation

The **Railtracks Instrumentation** instrument visualizes nodes, edges, and
per-LLM-call metrics from an `RTSFlowGraph` JSON file. It exposes five views:

- **Flow Tree** — 5-level aggregation (`a0`→`a4`) of agent/tool nodes with
  model, provider, tokens, latency, cost, and start-time columns. The depth is
  configurable — see [Changing the Flow Tree depth](#changing-the-flow-tree-depth).
- **Flow Object Graph** — directed parent→child object graph of agent and tool
  nodes
- **Tool I/O** — flat list of every input/output message (prompt, tool-call,
  arg, kwarg, transcript); select a row to see its full content in the right
  Extended Detail pane. A grouped **Tool I/O Summary** rolls these up by
  tool → Input/Output.
- **Call Tree** — emit-site backtraces with click-to-source jumps
- **Agent Runs** — per-agent duration bars on a timeline (red on error)

The signpost emission lives in the
[RailtracksInstrumentationKit](https://github.com/RailtownAI/railtracks-swift-visualizer-instruments)
Swift package; **JSONTools** depends on it (resolved from GitHub via Swift
Package Manager), constructs the events from the JSON, and emits them.

### Run

1. Open `VisualizerInstruments.xcodeproj` in Xcode.
2. Build & install the **RailtracksInstrumentation** package — see
   [Installing the Instruments packages](#installing-the-instruments-packages).
3. Launch **Instruments** and choose the **Railtracks Instrumentation** template.
4. Select the **JSONTools** scheme in Xcode and press `⌘R` to launch the
   companion app. Set JSONTools as the recording target in Instruments and
   press record.
5. In JSONTools, load an `RTSFlowGraph` JSON via **Choose File…** or by
   pasting a URL and pressing **Fetch**. Sample files live in `resources/`
   (e.g. `Orchestration_Flow_for_Job_0_*.json`).
6. The app emits `os_signpost` events that the instrument captures and renders
   across all five views. Loading a JSON also replays each agent as a
   begin/end interval, so the **Agent Runs** lane fills in.

### Schema

- **Package id:** `io.railtown.VisualizerInstruments.RailtracksInstrumentation`
- **Subsystem:** `io.railtown.visualizer.observability`
- **Category:** `Observation`
- **Signal names:** `FlowTreeNode`, `FlowGraphNode`, `FlowIO`, `AgentRun`

### Changing the Flow Tree depth

The Flow Tree is a fixed-depth aggregation. Each node's ancestor chain is
written into slots `a0`…`a4` (the node's own name sits at its depth; deeper
slots get a `·` filler), and the aggregation groups by those slots. **Today the
depth is capped at 5** in two places that must stay in sync:

- **Schema** — `RailtracksInstrumentation/RailtracksInstrumentation.instrpkg`:
  the `FlowTreeNode` `<pattern>` captures `a0`…`a4`, there are five
  `flow-tree-a0`…`flow-tree-a4` columns, and the Flow Tree `<aggregation>` has
  five `<level>` entries.
- **SDK** — `RailtracksInstrumentationKit` `RailtracksSignposts.emit(_ event:
  FlowTreeNode)`: the signpost message emits `a0=…` through `a4=…`.

> ⚠️ A node deeper than 5 levels currently **loses its name** — its name would
> land in `a5`, which isn't emitted. If your agent trees go deeper than 5, you
> must increase the depth (below), not just pass a longer `ancestors` array.

**To reduce the depth** (schema-only, no SDK change): delete the trailing
`<level>` line(s) from the Flow Tree `<hierarchy>`, rebuild the package, and
reinstall. Fewer levels = a shallower view (deeper nodes fold into their
ancestor's group) and **fewer roll-up rows** — which also lowers the data
volume the analysis core has to sort (relevant if you hit "resource cost too
high" / core-breach warnings).

**To increase the depth** (e.g. to 7 levels, `a0`…`a6`) — edit both sides, then
rebuild + reinstall the package and rebuild the SDK consumer:

1. **SDK** — in `emit(_ event: FlowTreeNode)`, add the new slots to the message
   before `name=…`:
   ```swift
   a5=\(a(5), privacy: .public) \
   a6=\(a(6), privacy: .public) \
   ```
   The `a(_:)` helper already handles any index, so no other SDK change is
   needed. (Then publish the SDK and bump the consuming app's package pin.)
2. **Schema** — in the `FlowTreeNode` `<pattern>`, add `" a5=" ?a5 " a6=" ?a6`
   before `" name="`; add matching `flow-tree-a5` / `flow-tree-a6` `<column>`s
   (copy an existing `flow-tree-a*` column); and add two `<level>` entries to
   the Flow Tree `<aggregation>`'s `<hierarchy>`.

Trade-off to keep in mind: more levels means more **filler rows** for shallow
nodes (each shallow node spans every level down to the deepest), which both
clutters the view and increases the row count the live analysis core must
sort. Apple's reference nominally lists a hierarchy cap around 4 levels; the
builder currently accepts 5, so if you push well past that, confirm the package
still validates after `xcodebuild … -scheme RailtracksInstrumentation build`.

---

## LLM Observation

The **LLM Observation** instrument tracks three signpost dimensions as a
process runs:

| Lane         | Schema                 | What it captures                                 |
| ------------ | ---------------------- | ------------------------------------------------ |
| Conversation | `os-signpost-interval` | Full conversation span (start → end)             |
| Actors       | `os-signpost-interval` | Per-role turn duration, color-coded by role      |
| Tokens       | `os-signpost-point`    | Individual token emissions with role and content |

The **Sample** app is an AI conversation simulator — a three-panel SwiftUI
window that replays configurable conversation scenarios with per-token
streaming.

### Run

1. Open `VisualizerInstruments.xcodeproj` in Xcode.
2. Build & install the **VisualizerInstruments** package — see
   [Installing the Instruments packages](#installing-the-instruments-packages).
3. Launch **Instruments** and choose the **LLM Observation** template.
4. Select the **Sample** scheme in Xcode and press `⌘R`. Set Sample as the
   recording target in Instruments and start a conversation simulation.

### Sample App

- **Scenarios** — built-in presets (simple Q&A, tool-use, multi-turn)
- **Modes** — token-by-token streaming or instant full-message delivery
- **Speed** — adjustable playback rate
- **Tool calls** — toggle to include assistant tool-call turns

Simulation state is driven by `SimulatorState` via `Task.detached`, with all UI
mutations dispatched to `MainActor` and cancellation checked after every
suspension point.

### Schema

- **Package id:** `VisualizerInstruments`
- **Subsystem:** `io.czrml.visualizer.observability`
- **Category:** `Observation`
- **Signal names:** `Conversation`, `Actor`, `Token`

Actor lane colors: `user` → Blue · `assistant` → Purple · `system` → Red ·
`tool` → Orange · other → Green.

---

## References

- [Instruments Developer Help](https://help.apple.com/instruments/developer/mac/current/)
  — `.instrpkg` XML schema reference
