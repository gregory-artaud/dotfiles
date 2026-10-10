#!/usr/bin/env python3
"""Back up existing managed files before chezmoi apply, with private permissions."""
import os
from pathlib import Path
import subprocess
import sys
import tarfile
from datetime import datetime, timezone


def main():
    repo, config = sys.argv[1:3]
    root = Path(sys.argv[3]).resolve() if len(sys.argv) > 3 else Path.home()
    paths = subprocess.check_output(
        ["chezmoi", "--source", repo, "--config", config, "managed",
         "--destination", str(root), "--path-style", "relative",
         "--nul-path-separator", "--include", "dirs,files,symlinks"], text=True
    ).rstrip("\0").split("\0")
    paths.append(".alacritty.toml")
    backup_dir = root / ".local/state/dotfiles/backups"
    backup_dir.mkdir(mode=0o700, parents=True, exist_ok=True)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ")
    destination = backup_dir / f"before-apply-{stamp}.tar.gz"
    # Exclusive creation prevents overwriting an older backup.
    fd = os.open(destination, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    count = 0
    with os.fdopen(fd, "wb") as stream, tarfile.open(fileobj=stream, mode="w:gz") as archive:
        for relative in sorted(set(paths)):
            if not relative:
                continue
            path = Path(relative)
            if path.is_absolute() or ".." in path.parts:
                raise ValueError("Unexpected managed path")
            source = root / path
            if source.is_dir() and not source.is_symlink():
                continue
            if source.exists() or source.is_symlink():
                archive.add(source, arcname=relative, recursive=False)
                count += 1
    print(f"Sauvegarde privée : {destination} ({count} fichiers/liens)")


if __name__ == "__main__":
    main()
