#!/usr/bin/env python3
"""Create a new repository in the DarIAData package following DATA.md.

Usage:
    python3 scripts/codegen/new_repo.py --name Users --type remote
    python3 scripts/codegen/new_repo.py --name Settings --type local --storage userdefaults

Every repository goes in Sources/DarIAData/Repositories/<Name>/, with its DAOs in DAO/.
Remote repositories call services through Core/Remote/NetworkClient. Their configuration is left empty
(baseURL "" and serviceNames []).
Local repositories store data on the device, with their storage in Local/, using one of: json (JSON files),
swiftdata (SwiftData), userdefaults (UserDefaults) or keychain (Keychain).

Every repository gets its public API, the public request/response protocols and the internal DAOs.
It is then registered in DATA.md and in scripts/codegen/project.json.
"""
from __future__ import annotations

import argparse
import json
import re

from common import (CODEGEN_DIR, ROOT, TEMPLATES, CodegenError, append_in_section, load_config, lower_camel,
                    main_wrapper, pascal_case, render, write_new)

COMMON_FILES = [
    ("Repository.swift.tmpl", "{R}Repository.swift"),
    ("RequestProtocol.swift.tmpl", "{R}RequestProtocol.swift"),
    ("ResponseProtocol.swift.tmpl", "{R}ResponseProtocol.swift"),
    ("DAO/RequestDAO.swift.tmpl", "DAO/{R}RequestDAO.swift"),
    ("DAO/ResponseDAO.swift.tmpl", "DAO/{R}ResponseDAO.swift"),
]
LOCAL_FILES = COMMON_FILES + [("Local/Storage.swift.tmpl", "Local/{R}Storage.swift")]
SWIFTDATA_FILES = COMMON_FILES + [("DAO/Entity.swift.tmpl", "DAO/{R}Entity.swift"),
                                  ("Local/Store.swift.tmpl", "Local/{R}Store.swift")]

# storage -> (label, store built by the repository's init)
KEY_VALUE_STORAGES = {
    "json": ("JSON files", "JSONFileStore()"),
    "userdefaults": ("UserDefaults", "UserDefaultsStore()"),
    "keychain": ("the Keychain", "KeychainStore()"),
}
STORAGE_LABELS = {"json": "JSON files", "swiftdata": "SwiftData", "userdefaults": "UserDefaults", "keychain": "Keychain"}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--name", required=True, help="Repository name, e.g. Users (a trailing 'Repository' is removed)")
    parser.add_argument("--type", required=True, choices=["remote", "local"],
                        help="remote: calls services. local: stores data on the device")
    parser.add_argument("--storage", choices=sorted(STORAGE_LABELS),
                        help="Required for --type local: json, swiftdata, userdefaults or keychain")
    args = parser.parse_args()

    if args.type == "local" and not args.storage:
        raise CodegenError("--storage is required for a local repository: json, swiftdata, userdefaults or keychain.")
    if args.type == "remote" and args.storage:
        raise CodegenError("--storage only applies to local repositories.")

    config = load_config()
    name = pascal_case(re.sub(r"\s*[Rr]epository$", "", args.name.strip()))
    sources = ROOT / config["dataSources"]
    registry = config.setdefault("repositories", {})
    repo_dir = sources / "Repositories" / name
    if name in registry or repo_dir.exists():
        raise CodegenError(f"Repository '{name}' already exists.")

    folder_name = "Remote" if args.type == "remote" else "Local"
    values = {"Repo": name}
    if args.type == "remote":
        template_dir, files = TEMPLATES / "repo" / "remote", COMMON_FILES
    elif args.storage == "swiftdata":
        template_dir, files = TEMPLATES / "repo" / "swiftdata", SWIFTDATA_FILES
    else:
        template_dir, files = TEMPLATES / "repo" / "local", LOCAL_FILES
        label, store = KEY_VALUE_STORAGES[args.storage]
        # Keys are "<module>.<repository>", e.g. "myAppData.settings", so they never clash with other code.
        key = f"{lower_camel(config['name'] + 'Data')}.{lower_camel(name)}"
        values.update({"StorageName": label, "StoreInit": store, "key": key})

    created = []
    for template_name, destination in files:
        path = repo_dir / destination.format(R=name)
        write_new(path, render(template_dir / template_name, values))
        created.append(str(path.relative_to(ROOT)))

    package_dir = sources.parent.parent
    data_md = package_dir / "DATA.md"
    storage = STORAGE_LABELS[args.storage] if args.storage else "—"
    folder = repo_dir.relative_to(package_dir)
    append_in_section(data_md, "repository-registry",
                      f"| `{name}` | {folder_name} | {storage} | `{name}RepositoryProtocol` | `{folder}` |")

    registry[name] = {"type": args.type, "storage": args.storage}
    (CODEGEN_DIR / "project.json").write_text(json.dumps(config, indent=2) + "\n", encoding="utf-8")

    print(f"Repository {name} created ({folder_name}{', ' + storage if args.storage else ''}).")
    print("Files:\n  " + "\n  ".join(created))
    if args.type == "remote":
        print(f"Next: fill in baseURL and serviceNames in {name}Repository.configuration, and the fields of "
              f"{name}RequestProtocol / {name}ResponseProtocol and their DAOs.")
    elif args.storage == "swiftdata":
        print(f"Next: declare the fields of {name}RequestProtocol / {name}ResponseProtocol, the stored properties "
              f"of {name}Entity, and copy them in {name}RequestDAO and {name}ResponseDAO.")
    else:
        print(f"Next: declare the fields of {name}RequestProtocol / {name}ResponseProtocol and add them to "
              f"{name}RequestDAO and {name}ResponseDAO with the same coding keys.")
    print(f"Updated: {data_md.relative_to(ROOT)}, scripts/codegen/project.json")
    return 0


if __name__ == "__main__":
    main_wrapper(main)
