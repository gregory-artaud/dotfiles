#!/usr/bin/env python3
"""Read-only checks to run after logging into the new laptop's i3 session."""
from pathlib import Path
import os
import shutil
import subprocess
import sys


def main():
    failures = []

    def check(ok, name):
        print(f"{'OK' if ok else 'À VÉRIFIER'} : {name}")
        if not ok:
            failures.append(name)

    for command in ["alacritty", "zsh", "i3", "i3lock", "xss-lock", "picom", "autotiling",
                    "autorandr", "feh", "yazi", "spectacle", "zen-browser", "nvim", "zeditor",
                    "docker", "dbeaver", "wg", "node", "pnpm", "codex", "pactl", "playerctl"]:
        check(bool(shutil.which(command)), f"commande {command}")
    root = Path.home()
    for name in ["gisland", "gislandctl", "gisland-lua-host", "context7-mcp"]:
        check(os.access(root / ".local/bin" / name, os.X_OK), f"exécutable {name}")
    for name in ["id_github", "id_home_lab"]:
        path = root / ".ssh" / name
        check(path.is_file() and path.stat().st_mode & 0o077 == 0, f"clé SSH privée {name}")
    for name in ["gisland.service", "dotfiles-ssh-agent.service"]:
        result = subprocess.run(["systemctl", "--user", "is-active", "--quiet", name])
        check(result.returncode == 0, f"service utilisateur {name}")
    result = subprocess.run(["systemctl", "is-active", "--quiet", "docker.service"])
    check(result.returncode == 0, "service Docker")
    check(bool(os.environ.get("DISPLAY")), "session X11")
    result = subprocess.run(["pgrep", "-x", "xss-lock"], capture_output=True)
    check(result.returncode == 0, "verrouillage automatique xss-lock")
    result = subprocess.run(["pgrep", "-x", "dunst"], capture_output=True)
    check(result.returncode != 0, "absence de Dunst concurrent")
    print("\nEssais manuels : verrouiller, suspendre/réveiller, volume, micro, luminosité,")
    print("capture d’écran, lanceur, notifications, écrans, VPN, GitHub et home_lab.")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
