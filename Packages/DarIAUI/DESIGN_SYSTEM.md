# DarIAUI — configuration

The `DarIAUI` package holds the design system of `DarIA`, generated from a Claude Design design system, and the components built on it.
Feature views only add these components. They never set colors, fonts, spacing or corner radii themselves.

## Source of truth

- `tokens.json` (this folder) is the tokens export of the Claude Design design system. In Claude Design it is `project/tokens.json`.
- `Sources/DarIAUI/Tokens/*.swift` and `Sources/DarIAUI/Resources/Colors.xcassets` are **generated** from it. Do not edit them by hand.
- To update the design system, replace `tokens.json` and run:

```
python3 scripts/codegen/design_tokens.py Packages/DarIAUI/tokens.json Packages/DarIAUI
```

## Tokens

| Swift type | Contents |
|---|---|
| `DSPalette` | Every color token, with light and dark values, from the asset catalog. |
| `DSColor` | Semantic roles used by the components: `background`, `surface`, `textPrimary`, `textSecondary`, `accent`, `onAccent`, `fillSecondary`, `destructive`, `onDestructive`, `separator`. |
| `DSTypeScale` / `DSFont` | Every type style / semantic fonts: `largeTitle`, `title`, `headline`, `body`, `bodyStrong`, `footnote`, `caption`. |
| `DSSpacing` | Every spacing token, plus `xSmall`, `small`, `medium`, `large`, `xLarge` and `tapMin`. |
| `DSRadius` | Every radius token, plus `small`, `control` and `card`. |

Custom fonts named in the tokens must be added to the app bundle (`.ttf`/`.otf`) and registered under `UIAppFonts` (iOS) or `ATSApplicationFontsPath` (macOS). Until then, SwiftUI falls back to the system font.

## Components

| Component | Use |
|---|---|
| `DSScreen { … }` | Root container of every screen: scroll view, background and margins. |
| `DSText(_:style:color:)` | Any text. |
| `DSButton(_:style:action:)` | Actions. Styles: `.primary`, `.secondary`, `.destructive`. |
| `DSTextField(_:value:)` | Text input. The first parameter is the placeholder. |
| `DSToggle(_:isOn:)` | Switch with a label. |
| `DSSectionHeader(_:)` | Header above a group of rows. |
| `DSListRow(_:subtitle:showsChevron:)` | Row in a list. |
| `DSCard { … }` | Groups content on a surface. |
| `DSIconButton(systemImage:label:action:)` | Icon-only bar button, 44 pt target, tinted with `accent`. |
| `DSChatBubble(_:sender:)` | Chat message. `.assistant` on `surface` (left), `.user` on `accent` (right). |
| `DSComposer(_:message:canSend:labels:onAttach:onSend:)` | Message bar: attach, capsule field, send. |
| `DSMenuPanel(width:) { … }` | Floating drop-down on `menu-surface` with `shadow-menu`. |
| `DSMenuScrim(label:onDismiss:)` | Veil behind an open menu; tapping it closes the menu. |
| `DSMenuRow(_:systemImage:showsDivider:action:)` | Menu entry with a trailing icon. |
| `DSConnectionRow(_:detail:badge:isSelected:action:)` | Selectable connection with check mark and identity badge. |
| `DSIdentityBadge(_:identity:size:)` / `DSIdentity` | Initial on the identity color of Claude, OpenAI, Gemini or a local machine. |

New components go in `Sources/DarIAUI/Components/`, use only tokens, are `public` and include a `#Preview`. A component that shows text conforms to `DSLocalizableText`.

## Localisation: `.localized(_:)`

Every component that shows text conforms to `DSLocalizableText` and gets a public `localized` extension. It receives a key, localises it and returns the component with the localised text:

```swift
DSText(style: .largeTitle).localized("profile.title")
DSButton { viewModel.save() }.localized("profile.save")
DSTextField(value: $email).localized("login.email.placeholder")
```

Keys are looked up in the app's `Localizable.xcstrings` (`Bundle.main`). Pass `table:` and `bundle:` to use another catalog. Because the key is passed as a value, Xcode does not extract it automatically, so add every new key to the String Catalog.
