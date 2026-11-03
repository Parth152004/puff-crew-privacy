"""Build locally; never upload. Keep the private signing backup outside this folder.

Python 3.9+. Godot 4.7.2 + matching export templates, Java 17 and Android SDK
must be installed/configured first. See handoff/BUILD-ON-ANOTHER-PC.md.
"""
from pathlib import Path
import argparse
import configparser
import json
import os
import re
import secrets
import shutil
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]


def release_settings(root):
    """Reject mismatched release identity before creating keys or launching builds."""
    config = json.loads((root / 'release/release-config.json').read_text())
    presets = configparser.ConfigParser(interpolation=None, delimiters=('=',))
    presets.read(root / 'puff-crew/export_presets.cfg')
    section = next((s + '.options' for s in presets.sections()
                    if presets[s].get('name') == '"Google Play"'), None)
    if section is None or section not in presets:
        raise ValueError('Google Play export preset is missing.')
    options = presets[section]
    version = options['version/name'].strip('"')
    code = int(options['version/code'])
    package = options['package/unique_name'].strip('"')
    source = (root / 'puff-crew/scripts/release_info.gd').read_text()
    match = re.search(r'const VERSION\s*=\s*"([^"]+)"', source)
    if not match or match.group(1) != version or config['version_name'] != version:
        raise ValueError('Version mismatch: align CrewRelease.VERSION, the Google Play '
                         'preset and release/release-config.json before release.')
    if int(config['version_code']) != code or config['package'] != package:
        raise ValueError('Package/versionCode mismatch between release config and preset.')
    if code < 1 or not re.fullmatch(r'[0-9A-Za-z._-]+', version):
        raise ValueError('Invalid version or versionCode.')
    return version, code, package


def default_signing_dir():
    if sys.platform == 'darwin':
        base = Path.home() / 'Library/Application Support'
    elif os.name == 'nt':
        base = Path(os.environ.get('LOCALAPPDATA', str(Path.home() / 'AppData/Local')))
    else:
        base = Path(os.environ.get('XDG_DATA_HOME', str(Path.home() / '.local/share')))
    return base / 'Ramo Labs/Puff Crew/signing'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true',
                        help='Check release identity only; no tools, keys or builds started.')
    parser.add_argument('--create-upload-key', action='store_true',
                        help='Create a new private key only if credentials/key are absent.')
    args = parser.parse_args()
    version, code, package = release_settings(ROOT)
    print(f'Release identity: {package} / {version} / code {code}')
    if args.check:
        print('Identity matches. This does not check Play access, billing, privacy or device QA.')
        return
    env = os.environ.copy()
    java_home = env.get('JAVA_HOME')
    keytool = str(Path(java_home) / 'bin' / ('keytool.exe' if os.name == 'nt' else 'keytool')) if java_home else shutil.which('keytool')
    godot = env.get('GODOT_BIN') or shutil.which('godot')
    if not keytool or not Path(keytool).is_file():
        raise ValueError('Set JAVA_HOME to Java 17, or put its keytool on PATH.')
    if not godot or not Path(godot).is_file():
        raise ValueError('Set GODOT_BIN to the Godot executable, or put godot on PATH.')
    sign = Path(env.get('PUFF_SIGNING_DIR', str(default_signing_dir()))).expanduser().resolve()
    if sign == ROOT or ROOT in sign.parents:
        raise ValueError('Keep PUFF_SIGNING_DIR outside the source/handoff folder.')
    secret = sign / 'upload-credentials.json'
    if not secret.exists():
        if not args.create_upload_key:
            raise ValueError('Upload credentials missing. Restore the owner signing backup '
                             'or deliberately use --create-upload-key for a new identity.')
        sign.mkdir(parents=True, exist_ok=True)
        sign.chmod(0o700)
        keystore = sign / 'puff-crew-upload.jks'
        if keystore.exists():
            raise ValueError('Key exists without credentials; restore its credentials rather than overwrite it.')
        cfg = {'keystore': str(keystore), 'alias': 'ramolabs-upload', 'password': secrets.token_hex(32)}
        env['RAMO_UPLOAD_PASSWORD'] = cfg['password']
        subprocess.run([keytool, '-genkeypair', '-keystore', str(keystore), '-alias', cfg['alias'],
                        '-storetype', 'JKS', '-keyalg', 'RSA', '-keysize', '3072', '-validity', '10000',
                        '-dname', 'CN=Ramo Labs, OU=Game Development', '-storepass:env',
                        'RAMO_UPLOAD_PASSWORD', '-keypass:env', 'RAMO_UPLOAD_PASSWORD'],
                       env=env, check=True, capture_output=True)
        keystore.chmod(0o600)
        fd = os.open(secret, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
        with os.fdopen(fd, 'w') as stream:
            json.dump(cfg, stream)
        print('Created private upload key outside the project. Back up the signing folder securely.')
    else:
        cfg = json.loads(secret.read_text())
        keystore = Path(cfg['keystore']).expanduser()
        # Restored credentials can still reference the original PC's absolute path.
        if not keystore.is_file():
            keystore = sign / 'puff-crew-upload.jks'
        if not keystore.is_file():
            raise ValueError('Private keystore missing from restored signing folder.')
    env['RAMO_UPLOAD_PASSWORD'] = cfg['password']
    env['GODOT_ANDROID_KEYSTORE_RELEASE_PATH'] = str(keystore)
    env['GODOT_ANDROID_KEYSTORE_RELEASE_USER'] = cfg['alias']
    env['GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD'] = cfg['password']
    out = ROOT / 'builds/release'
    out.mkdir(parents=True, exist_ok=True)
    project = ROOT / 'puff-crew'
    with (out / 'import.log').open('w') as log:
        subprocess.run([godot, '--headless', '--path', str(project), '--editor', '--import', '--quit'],
                       env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
    command = [godot, '--headless', '--path', str(project)]
    if not (project / 'android/build/gradlew').exists():
        command.append('--install-android-build-template')
    artifact = out / f'Puff-Crew-{version}.aab'
    with (out / 'export-aab.log').open('w') as log:
        subprocess.run(command + ['--export-release', 'Google Play', str(artifact)],
                       env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
    subprocess.run([keytool, '-exportcert', '-rfc', '-keystore', str(keystore), '-alias', cfg['alias'],
                    '-storepass:env', 'RAMO_UPLOAD_PASSWORD', '-file', str(out / 'upload-certificate.pem')],
                   env=env, check=True, capture_output=True)
    print(f'AAB: {artifact}\nPublic upload certificate: {out / "upload-certificate.pem"}')
    print('Local export only. Validate the final bundle and devices before Play testing/submission.')


if __name__ == '__main__':
    try:
        main()
    except (ValueError, KeyError, OSError, subprocess.CalledProcessError) as error:
        raise SystemExit(str(error))
