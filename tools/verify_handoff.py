"""Verify this extracted handoff with Python's standard library; no external tools."""
from pathlib import Path, PurePosixPath
import hashlib
import json
import sys


def digest(path):
    value = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            value.update(chunk)
    return value.hexdigest()


def main():
    root = Path(__file__).resolve().parents[1]
    manifest = json.loads((root / 'MANIFEST.json').read_text())
    entries = manifest['files']
    expected = {entry['path']: entry for entry in entries}
    if len(expected) != len(entries):
        raise ValueError('Duplicate manifest paths.')
    sums = {}
    for line in (root / 'SHA256SUMS.txt').read_text().splitlines():
        sha, path = line.split('  ', 1)
        if path in sums:
            raise ValueError('Duplicate checksum paths.')
        sums[path] = sha
    if set(sums) != set(expected) | {'MANIFEST.json'}:
        raise ValueError('Checksum and manifest file sets differ.')
    failed = []
    for relative, sha in sums.items():
        parts = PurePosixPath(relative)
        if parts.is_absolute() or '..' in parts.parts or '\\' in relative:
            raise ValueError('Unsafe path in manifest.')
        path = root / relative
        if not path.is_file() or path.is_symlink():
            failed.append(relative + ': missing or symlink')
            continue
        if digest(path) != sha:
            failed.append(relative + ': SHA-256 mismatch')
        if relative in expected:
            entry = expected[relative]
            if path.stat().st_size != entry['bytes'] or sha != entry['sha256']:
                failed.append(relative + ': manifest mismatch')
    if failed:
        raise ValueError('\n'.join(failed))
    print(f'PASS: {len(sums)} files match sizes/hashes. No servers or build tools started.')


if __name__ == '__main__':
    try:
        main()
    except (OSError, ValueError, KeyError) as error:
        print(f'FAIL: {error}', file=sys.stderr)
        raise SystemExit(1)
