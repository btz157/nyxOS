# NyxOS roadmap

## Implemented in the current source tree (not yet Studio-validated)
- [x] Theme palettes: Matrix, Neon, Dark, Light
- [x] Animated opening window and draggable top bar
- [x] Tabs and scrollable tab pages
- [x] Minimize/restore orb
- [x] Timed toast notifications
- [x] Button, toggle, slider, dropdown, textbox and label modules
- [x] Section headings, dividers and progress bar
- [x] Starter example and API notes

## Next engineering tasks
- [ ] Run Rojo build and verify the exact instance hierarchy
- [ ] Test every component in Roblox Studio on mouse and touch
- [ ] Add automated static checks / Luau linting
- [ ] Ensure every event connection is disconnected when the UI is destroyed
- [ ] Improve dropdown scrolling for long option lists
- [ ] Add textbox validation and optional live-change callbacks
- [ ] Add slider keyboard/gamepad accessibility and robust pointer capture
- [ ] Add window resize support and responsive layouts
- [ ] Add theme switching at runtime
- [ ] Add icon abstraction and accessibility labels
- [ ] Add confirmation dialogs and keybind control
- [ ] Generate and test deterministic `dist/NyxOS.lua` bundle
- [ ] Add release tags and changelog

## Release gate
Do not mark a release as stable until the modular and bundled builds are tested in Roblox Studio and the example runs without errors.
