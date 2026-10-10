#!/usr/bin/env bash
# Explicit encrypted export/import, independent of chezmoi apply.
set -euo pipefail
umask 077

case ${1:-help} in
    export|import)
        [[ $# == 2 ]] || { printf 'Usage : %s %s fichier.tar.gpg\n' "$0" "$1" >&2; exit 1; }
        ;;
    *)
        printf '%s\n' \
            'Sur le serveur : gpg-transfer.sh export /chemin/cles-serveur.tar.gpg' \
            'Transférer ce fichier chiffré vers le laptop via SSH.' \
            'Sur le laptop : gpg-transfer.sh import /chemin/cles-serveur.tar.gpg' \
            'Les exports/imports demandent les phrases secrètes via GPG.'
        exit 0
        ;;
esac

temporary_dir=$(mktemp -d)
trap 'rm -rf -- "$temporary_dir"' EXIT

if [[ $1 == export ]]; then
    [[ ! -e $2 ]] || { printf 'Le fichier de sortie existe déjà.\n' >&2; exit 1; }
    gpg --export-secret-keys > "$temporary_dir/secret-keys.asc"
    [[ -s $temporary_dir/secret-keys.asc ]] || { printf 'Aucune clé privée GPG exportée.\n' >&2; exit 1; }
    gpg --export-ownertrust > "$temporary_dir/ownertrust.txt"
    tar -C "$temporary_dir" -cf - secret-keys.asc ownertrust.txt | \
        gpg --symmetric --cipher-algo AES256 --output "$2"
    printf 'Export chiffré créé : %s\n' "$2"
else
    gpg --decrypt --output "$temporary_dir/keys.tar" "$2"
    # Extract only the two expected regular files, never archive paths or links.
    python3 - "$temporary_dir" <<'PY'
from pathlib import Path
import sys
import tarfile
root = Path(sys.argv[1])
with tarfile.open(root / "keys.tar") as archive:
    for name in ["secret-keys.asc", "ownertrust.txt"]:
        member = archive.getmember(name)
        if not member.isfile():
            raise ValueError("Expected a regular file")
        with archive.extractfile(member) as source:
            (root / name).write_bytes(source.read())
PY
    gpg --import "$temporary_dir/secret-keys.asc"
    gpg --import-ownertrust "$temporary_dir/ownertrust.txt"
    printf 'Clés et niveaux de confiance GPG du serveur importés.\n'
fi
