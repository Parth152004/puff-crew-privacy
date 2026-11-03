"""Run the actual APK as Android host and Android client in two emulators.

Android Emulator 36.5+ connects both instances through virtual Wi-Fi. This validates
Android ENet hosting, ready/start, both touch streams and state replication. It does
not replace physical phones on a home Wi-Fi router. Discovery is recorded separately.
"""
from pathlib import Path
import json,shlex,subprocess,time,os,sys
ROOT=Path(__file__).resolve().parents[1]
PKG='com.puffcrew.rapids'
HOST=sys.argv[1] if len(sys.argv)>1 else 'emulator-5554'
CLIENT=sys.argv[2] if len(sys.argv)>2 else 'emulator-5556'
OUT=Path(os.environ.get('PUFF_QA_OUTPUT',str(ROOT/'builds')))
OUT.mkdir(parents=True,exist_ok=True)
APK=Path(os.environ.get('PUFF_QA_APK',str(ROOT/'builds/Puff-Crew-0.2.0-Playtest.apk')))

def adb(serial,*args,check=True):
 p=subprocess.run(['adb','-s',serial]+list(args),capture_output=True,check=check,timeout=30)
 return p

def read(serial,file):
 p=adb(serial,'exec-out','run-as',PKG,'cat','files/'+file,check=False)
 if p.returncode==0:
  try:return json.loads(p.stdout)
  except json.JSONDecodeError:pass
 return None

for serial,mode in [(HOST,'host'),(CLIENT,'client')]:
 for _ in range(100):
  if adb(serial,'shell','getprop','sys.boot_completed',check=False).stdout.strip()==b'1':break
  time.sleep(.5)
 else:raise RuntimeError(f'{serial} did not boot')
 print(serial,adb(serial,'install','--no-incremental','-r',str(APK)).stdout.decode(),flush=True)
 adb(serial,'shell','am','force-stop',PKG)
 adb(serial,'shell','run-as',PKG,'mkdir','-p','files')
 adb(serial,'shell','run-as',PKG,'rm','-f','files/qa-result.json','files/qa-host-ready.json')
 cmd="printf '%s\\n' "+shlex.quote(mode)+" > files/qa_mode.txt"
 adb(serial,'shell','run-as '+PKG+' sh -c '+shlex.quote(cmd))

try:
 adb(HOST,'shell','am','start','-n',PKG+'/com.godot.game.GodotAppLauncher')
 for _ in range(80):
  ready=read(HOST,'qa-host-ready.json')
  if ready:break
  time.sleep(.5)
 else:raise RuntimeError('Android host did not become ready')
 cmd="printf '%s\\n' "+shlex.quote(ready['ip'])+" > files/qa_target.txt"
 adb(CLIENT,'shell','run-as '+PKG+' sh -c '+shlex.quote(cmd))
 adb(CLIENT,'shell','am','start','-n',PKG+'/com.godot.game.GodotAppLauncher')
 results={}
 for _ in range(110):
  for serial in [HOST,CLIENT]:
   r=read(serial,'qa-result.json')
   if r:results[serial]=r
  if len(results)==2:break
  time.sleep(.5)
 for serial in [HOST,CLIENT]:
  tag='host' if serial==HOST else 'client'
  logs=adb(serial,'logcat','-d','-s','godot:V','AndroidRuntime:E').stdout.decode()
  (OUT/f'android-pair-{tag}.log').write_text(logs)
  file='qa-host-coop.png' if serial==HOST else 'qa-coop.png'
  p=adb(serial,'exec-out','run-as',PKG,'cat','files/'+file,check=False)
  if p.returncode==0:(OUT/f'android-pair-{tag}.png').write_bytes(p.stdout)
 (OUT/'android-pair-qa.json').write_text(json.dumps(results,indent=2)+'\n')
 print(json.dumps(results,indent=2),flush=True)
 if len(results)!=2 or not all(r.get('pass') for r in results.values()):raise SystemExit(1)
finally:
 pass  # The QA runner creates no external network service or forwarding rule.
