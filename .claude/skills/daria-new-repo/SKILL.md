---
name: daria-new-repo
description: Create a new repository in the DarIA Networking package following Packages/Networking/NETWORKING.md. Use whenever the user wants to connect DarIA to a new API or service.
---

# New DarIA repository

1. Read `Packages/Networking/NETWORKING.md`.
2. Run the generator from the project root:
   ```bash
   python3 scripts/codegen/new_repo.py --name <Name>
   ```
   It creates `Packages/Networking/Sources/Networking/Repositories/<Name>/` with the public repository and API protocol, the public request/response protocols and the internal DAOs, with an empty configuration (`baseURL` "" and `serviceNames` []), and registers it in NETWORKING.md.
3. Fill in the configuration and the DAOs for the real API. Keep the DAOs internal; features only see the public protocols.
4. Inject the repository into the feature that uses it through its `<Feature>Dependencies` and consume it from the use case.
5. Lint each file you touch and run `(cd Packages/Networking && swift test)`.
