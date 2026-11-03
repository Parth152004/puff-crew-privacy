# Signing and owner-only transfer

The general developer ZIP intentionally contains **no private keystore, password, service-account JSON, Play credential or debug keystore**. `release/signing/upload-certificate.pem` is public and cannot sign an app.

A private upload key was created during earlier local preparation, outside the workspace. It was never uploaded or registered with Play here. Owner's current Mac location:

```text
~/Library/Application Support/Ramo Labs/Puff Crew/signing/
    puff-crew-upload.jks
    upload-credentials.json
```

Alias: `ramolabs-upload`. The JSON holds the password and original keystore path. Both files are sensitive. The owner should securely back up this directory before changing computers, then provide it separately to the authorized release developer through an encrypted transfer/password manager, with any transfer password sent separately. Do not send a combined unencrypted source/key/password ZIP or put it in source control. Local POSIX folder/file permissions were 0700/0600; use appropriate account ACLs on Windows.

On the receiving PC, restore the directory outside the handoff/source folder and set `PUFF_SIGNING_DIR` to it. The helper supports an obsolete original-machine path by using the adjacent `puff-crew-upload.jks`. Never put the password into shell command arguments, screenshots, issue trackers or shared build logs. Godot signing values are passed through the child environment by the helper.

Before any Play upload, the owner/developer must inspect the actual app/package and Play App Signing setup. This handoff did not inspect the Console. If an upload certificate is already registered, use that registered key or Google's supported reset process; don't silently replace it. If no identity is registered yet, decide deliberately whether to use this prepared upload key or create a new owner-controlled one. Play App Signing's app-signing key and the developer upload key serve different roles.

To inspect the included public certificate on a PC with OpenSSL:

```sh
openssl x509 -in release/signing/upload-certificate.pem -noout -subject -fingerprint -sha256
```

Export the restored keystore's public certificate using keytool with an interactive password prompt and compare certificate SHA-256 fingerprints before building. Keep private backups recoverable under owner control. Avoid sharing the owner's Google password; grant the developer appropriate Play Console access separately when the owner resumes publishing.

Reference: [Android app signing](https://developer.android.com/studio/publish/app-signing). No signing key was created, transferred or changed while packaging this handoff.
