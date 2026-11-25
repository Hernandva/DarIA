---
name: daria-new-repo
description: Create a new repository in the DarIA data package, DarIAData, either remote (calls to services) or local (data stored on the device with JSON files, SwiftData, UserDefaults or the Keychain), with its public protocols, internal DAOs and registry entry in DATA.md. Use it whenever the user wants a new repository, API, endpoint, service client, cache or local storage in DarIA, even if they don't say "repository".
---

# New DarIA repository

Repositories live in `Packages/DarIAData/Sources/DarIAData/Repositories/<Name>/` and follow
`RequestProtocol -> RequestDAO -> ResponseDAO -> ResponseProtocol`. Read `Packages/DarIAData/DATA.md`
before changing one. Never create the files by hand.

## 1. Ask, one question at a time

Ask each question in its own message and wait for the answer before asking the next. Skip any question the user has
already answered. When you have a multiple-choice question tool, use it for the questions with fixed options.

1. **Name** (`--name`): PascalCase, without the `Repository` suffix (`Users`, `Settings`). Check the repository
   registry in `DATA.md` so it does not exist yet.
2. **Remote or local?** (`--type`)
   - **Remote**: it calls services (an API) through `Core/Remote/NetworkClient`.
   - **Local**: it stores data on the device, with its storage in `Local/`.
3. **Only for local: which storage?** (`--storage`) Explain the options so the user can choose:
   - **JSON files** (`json`): documents and cached data of any size.
   - **SwiftData** (`swiftdata`): many records that are queried or related.
   - **UserDefaults** (`userdefaults`): small values such as settings or flags.
   - **Keychain** (`keychain`): sensitive data such as tokens or credentials.

## 2. Run the generator

```bash
python3 scripts/codegen/new_repo.py --name <Name> --type remote
python3 scripts/codegen/new_repo.py --name <Name> --type local --storage json|swiftdata|userdefaults|keychain
```

It creates the public `<Name>RepositoryProtocol` and `<Name>Repository`, the public `<Name>RequestProtocol`
and `<Name>ResponseProtocol`, the internal DAOs in `DAO/`, the storage in `Local/` for a local repository, and adds
the repository to the registry in `DATA.md`.

## 3. Fill it in

- **Remote configuration:** set `baseURL` and `serviceNames` in `<Name>Repository.configuration`, only with values
  the user gives you. Leave them empty otherwise and say so: calls throw `NetworkError` until they are set.
- **Protocols:** add to the request and response protocols the fields the repository needs, and mirror them in the
  DAOs. For JSON, UserDefaults and Keychain both DAOs must use the same coding keys; for SwiftData, add the stored
  properties to `<Name>Entity`.
- Keep the DAOs `internal`. Features only ever see the public protocols.
- **Own data sources:** put a provider SDK service in `Remote/<Provider>/`. Storage keys stay as the generator wrote
  them (`<module>.<repository>`). DAOs stay in `DAO/`.
- Never put secrets (API keys, client secrets, tokens) in the source. Ask the user where they should come from.

## 4. Test, lint and commit

1. `(cd Packages/DarIAData && swift test)` on a Mac with Xcode.
2. Lint each file you touched: `swiftlint lint --quiet <file>`, then `scripts/lint.sh`. New code adds zero violations.
3. Commit on the current feature branch (`feature/DarIA-<Feature>` from `develop`), or create one from `develop`.

To use the repository from a screen, create or update the feature with
`python3 scripts/codegen/new_feature.py --name <Feature> --parent <Parent> --repository <Name>`.
