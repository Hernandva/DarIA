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
| `DSIconButton(systemImage:label:action:)` | Icon-only 44 pt button tinted with `accent`; `label` is its accessibility label. |
| `DSNavigationTitle(_:subtitle:accessibilityLabel:action:)` | Tappable navigation-bar title with a subtitle and an up-down chevron (opens a picker). |
| `DSChatBubble(_:role:)` | Chat message. `role`: `.incoming` (assistant, `surface`) or `.outgoing` (user, `accent`). |
| `DSChatAttachment(_:role:)` | Image or file attached to a message, with its file name. |
| `DSChatTimestamp(day:time:)` | Centered date stamp above a group of messages. |
| `DSChatStatus(_:)` | Status under the user's last message («Delivered»). |
| `DSChatTypingIndicator(_:)` | Incoming bubble with pulsing dots while the assistant writes; the text is its accessibility label. |
| `DSChatNotice(_:)` | Centered notice in a conversation, such as an error of the model. |
| `DSChatComposer(message:texts:isSendEnabled:onAttach:onSend:)` | Chat bottom bar: attach button and growing message field with send. |

New components go in `Sources/DarIAUI/Components/`, use only tokens, are `public` and include a `#Preview`. A component that shows a single text conforms to `DSLocalizableText`; components with several texts take them already localised.

## Localisation: `.localized(_:)`

Every component that shows text conforms to `DSLocalizableText` and gets a public `localized` extension. It receives a key, localises it and returns the component with the localised text:

```swift
DSText(style: .largeTitle).localized("profile.title")
DSButton { viewModel.save() }.localized("profile.save")
DSTextField(value: $email).localized("login.email.placeholder")
```

For a plain SwiftUI `Text`, use `Text(forKey:value:)`. It looks the key up with `Bundle.localizedString(forKey:value:table:)`, and `value` is the text shown when the key is not in the catalog (without it, the key is shown):

```swift
Text(forKey: "profile.title", value: "Profile")
```

Keys are looked up in the app's `Localizable.xcstrings` (`Bundle.main`). Pass `table:` and `bundle:` to use another catalog. Both accept them. Because the key is passed as a value, Xcode does not extract it automatically, so add every new key to the String Catalog.
