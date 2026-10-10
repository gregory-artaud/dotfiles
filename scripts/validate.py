#!/usr/bin/env python3
"""Render and validate dotfiles in a private temporary home; execute no hooks."""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import tarfile
import tomllib


REPO = Path(__file__).resolve().parents[1]


def run(*args):
    result = subprocess.run(args, capture_output=True, text=True)
    if result.returncode:
        # None of the called commands emit decrypted file contents.
        raise RuntimeError(f"{args[0]} failed:\n{result.stderr}")
    return result.stdout


def require(condition, message):
    if not condition:
        raise AssertionError(message)


def check_source():
    for name in ["chezmoi", "bash", "zsh", "i3", "luac"]:
        require(shutil.which(name), f"Missing validation tool: {name}")
    run("git", "-C", str(REPO), "diff", "HEAD", "--check")
    run("bash", "-n", str(REPO / "scripts/setup.sh"))
    run("bash", "-n", str(REPO / "scripts/gpg-transfer.sh"))
    for path in (REPO / "scripts").glob("*.py"):
        compile(path.read_text(), str(path), "exec")
    for manifest in (REPO / "packages").glob("*.txt"):
        names = [line.split("#")[0].strip() for line in manifest.read_text().splitlines()]
        names = [name for name in names if name]
        require(len(names) == len(set(names)), f"Duplicate package in {manifest.name}")
    # These signatures catch actual credentials, not example API_KEY placeholders.
    signatures = [r"ctx7sk-[A-Za-z0-9-]{20,}", r"gh[pousr]_[A-Za-z0-9]{30,}",
                  r"github_pat_[A-Za-z0-9_]{30,}", r"-----BEGIN (?:OPENSSH |RSA |EC )?PRIVATE KEY-----"]
    for path in REPO.rglob("*"):
        if not path.is_file() or ".git" in path.parts or path.suffix == ".age":
            continue
        try:
            text = path.read_text()
        except UnicodeDecodeError:
            continue
        for signature in signatures:
            require(not re.search(signature, text), f"Possible plaintext credential: {path.relative_to(REPO)}")


def check_render(destination, encrypted):
    def file(name):
        path = destination / name
        require(path.is_file(), f"Missing target: {name}")
        return path

    require(not (destination / "scripts").exists(), "Repository scripts leaked into home")
    require(not (destination / "vendor").exists(), "Vendor sources leaked into home")
    require(not (destination / ".alacritty.toml").exists(), "Duplicate Alacritty config")
    for path in destination.rglob("*.toml"):
        tomllib.loads(path.read_text())
    for name in [".config/zed/settings.json", ".config/zed/keymap.json"]:
        json.loads(file(name).read_text())
    run("i3", "-C", "-c", str(file(".config/i3/config")))
    run("zsh", "-n", str(file(".zshrc")))
    run("zsh", "-n", str(file(".p10k.zsh")))
    for path in (destination / ".scripts").iterdir():
        run("bash", "-n", str(path))
        require(os.access(path, os.X_OK), f"Not executable: {path.name}")
    run("bash", "-n", str(file(".local/bin/context7-mcp")))
    for root in [destination / ".config/nvim", destination / ".config/gisland/modules/launcher"]:
        for path in root.rglob("*.lua"):
            run("luac", "-p", str(path))
    gisland = tomllib.loads(file(".config/gisland/config.toml").read_text())
    ids = {module["id"] for module in gisland["modules"] if module.get("enabled", True)}
    require(ids == {"clock", "audio", "notifications", "battery", "launcher", "power-menu"},
            f"Unexpected Gisland modules: {ids}")
    codex = tomllib.loads(file(".codex/config.toml").read_text())
    require(set(codex["mcp_servers"]) == {"context7"}, "Unexpected Codex MCP")
    require("plugins" not in codex and "projects" not in codex, "Old Codex local state retained")
    require("/home/gartaud" not in file(".codex/config.toml").read_text(), "Codex path not rendered")
    require(Path(codex["mcp_servers"]["context7"]["command"]).is_file(), "Missing MCP wrapper")
    require((destination / ".config/systemd/user/dunst.service").is_symlink(), "Dunst not masked")
    require(os.readlink(destination / ".config/systemd/user/dunst.service") == "/dev/null", "Invalid Dunst mask")
    require(os.readlink(destination / ".config/gisland/fonts") ==
            str(destination / ".local/share/gisland/distributed/fonts"), "Nonportable font symlink")
    i3 = file(".config/i3/config").read_text()
    for obsolete in ["tesserish", "polybar", "rofi", "opencode", "HDMI-A-0", "JetBrains"]:
        require(obsolete not in i3, f"Obsolete i3 setting: {obsolete}")
    require("xss-lock --transfer-sleep-lock -- i3lock --nofork" in i3, "Sleep lock not configured")
    require("zen-browser" in i3 and "Hack Nerd Font" in i3, "Browser/font not configured")
    for alias in ["bilal", "marc", "kevin", "gp-explorer", "pablo", "valentin", "jean", "arda", "git-vache", "donut-sucre-au-sucre"]:
        require(f"alias {alias}=" not in file(".zshrc").read_text(), f"Joke alias retained: {alias}")
    for name in [".config/polybar", ".config/rofi", ".config/sway", ".config/waybar", ".config/swaync",
                 ".config/hypr", ".config/opencode", ".config/gisland/modules/tesserish", ".gnupg",
                 ".codex/rules", ".codex/plugins", ".codex/skills/.system", ".ssh/id_home_zero"]:
        require(not (destination / name).exists(), f"Unwanted target: {name}")
    require(file(".agents/skills/code-review/SKILL.md"), "Shared skills missing")
    require(file(".codex/skills/frontend-design/SKILL.md"), "Personal skills missing")
    for name in ["run_eval.py", "run_loop.py"]:
        file(f".codex/skills/anthropic-skill-creator/scripts/{name}")
    run("ssh", "-G", "-F", str(file(".ssh/config")), "github.com")
    if encrypted:
        for name in [".ssh/id_github", ".ssh/id_home_lab", ".config/wg/wgHome.conf",
                     ".config/dotfiles/context7-api-key"]:
            path = file(name)
            require(path.stat().st_mode & 0o077 == 0, f"Secret permissions too broad: {name}")
        for name in ["id_github", "id_home_lab"]:
            # Structural check only: passphrases are tested manually on the laptop.
            require(file(f".ssh/{name}").read_text().splitlines()[0].endswith("OPENSSH PRIVATE KEY-----"),
                    f"Invalid decrypted SSH identity: {name}")
    print(f"PASS: rendered home, syntax, selected tools, services, skills{' and encrypted files' if encrypted else ''}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--identity", type=Path, help="Optional age identity; encrypted targets stay in the temporary home")
    args = parser.parse_args()
    check_source()
    with tempfile.TemporaryDirectory(prefix="dotfiles-validation-") as directory:
        root = Path(directory)
        destination = root / "home"
        destination.mkdir(mode=0o700)
        config = root / "config.toml"
        identity = args.identity.resolve() if args.identity else root / "unused-identity"
        config.write_text('encryption = "age"\n[age]\nidentity = ' + json.dumps(str(identity)) + '\n')
        common = ["chezmoi", "--source", str(REPO), "--destination", str(destination),
                  "--config", str(config), "--cache", str(root / "cache"),
                  "--persistent-state", str(root / "state.boltdb"), "--use-builtin-age=true"]
        exclude = "" if args.identity else "encrypted"
        # A legacy file exercises the one explicitly declared removal.
        (destination / ".alacritty.toml").write_text("# obsolete duplicate\n")
        (destination / ".zshrc").write_text("# previous shell\n")
        (destination / "existing-link").symlink_to("missing-target")
        run("python3", str(REPO / "scripts/backup.py"), str(REPO), str(config), str(destination))
        backup = next((destination / ".local/state/dotfiles/backups").glob("*.tar.gz"))
        require(backup.stat().st_mode & 0o077 == 0, "Backup permissions too broad")
        with tarfile.open(backup) as archive:
            require(set(archive.getnames()) == {".alacritty.toml", ".zshrc"}, "Unexpected backup contents")
            require(archive.extractfile(".zshrc").read() == b"# previous shell\n", "Backup lost original contents")
        print("PASS: pre-apply backup saves existing targets and removed file with private permissions")
        run(*common, "apply", "--force", "--exclude", exclude)
        check_render(destination, bool(args.identity))
        # Second application must be idempotent, including symlinks and removals.
        run(*common, "apply", "--force", "--exclude", exclude)
        status = run(*common, "status", "--exclude", exclude)
        require(not status.strip(), "Render is not idempotent")
        print("PASS: second application has no remaining changes; temporary home removed on exit")


if __name__ == "__main__":
    main()
