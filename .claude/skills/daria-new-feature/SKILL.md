---
name: daria-new-feature
description: Create a new feature (scene) in the DarIA app following DarIA/FEATURES.md. Use whenever the user wants a new screen, scene or flow in DarIA.
---

# New DarIA feature

1. Read `DarIA/FEATURES.md` to choose the parent feature that opens the new one.
2. Make sure the working tree is clean and `develop` is up to date.
3. Run the generator from the project root:
   ```bash
   python3 scripts/codegen/new_feature.py --name <Feature> --parent <ParentFeature> [--repository <Repository>]
   ```
   It creates `feature/DarIA-<Feature>` from `develop`, the folder `DarIA/Features/<Feature>/` (Coordinator, Dependencies, View, ViewModel, ViewData, UseCase), the route in the parent coordinator, the FEATURES.md registry entry and the `<feature>.title` key in `Localizable.xcstrings`, and regenerates the Xcode project when XcodeGen is installed.
4. Build the view only with `DarIAUI` components (see `Packages/DarIAUI/DESIGN_SYSTEM.md`). Add every new text key to `Localizable.xcstrings`.
5. Lint each file you touch (`swiftlint lint --quiet <file>`). New code adds zero violations.
6. Commit on the feature branch.
