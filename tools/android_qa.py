"""Install and instrument the debug APK on a running Android emulator.

Usage: python3 tools/android_qa.py solo|client [serial]
Client mode launches a temporary desktop ENet host and verifies both endpoints.
No device UI coordinates or personal apps are touched; the generated app handles QA.
"""
from pathlib import Path
import json,subprocess,sys,time,shlex,os
ROOT=Path(__file__).resolve().parents[1]
MODE=sys.argv[1] if len(sys.argv)>1 else 'solo'
SERIAL=sys.argv[2] if len(sys.argv)>2 else 'emulator-5554'
ADB=['adb','-s',SERIAL]
PKG='com.puffcrew.rapids'
OUT=Path(os.environ.get('PUFF_QA_OUTPUT',str(ROOT/'builds')))
OUT.mkdir(parents=True,exist_ok=True)
APK=Path(os.environ.get('PUFF_QA_APK',str(ROOT/'builds/Puff-Crew-0.2.0-Playtest.apk')))

def adb(*args,input=None,check=True):
 return subprocess.run(ADB+list(args),input=input,stdout=subprocess.PIPE,stderr=subprocess.PIPE,check=check,timeout=30)

def private_read(name):
 return adb('exec-out','run-as',PKG,'cat','files/'+name,check=False)

for _ in range(60):
 boot=adb('shell','getprop','sys.boot_completed',check=False)
 if boot.stdout.strip()==b'1': break
 time.sleep(.5)
else: raise SystemExit('Android did not finish booting')
print(adb('install','--no-incremental','-r',str(APK)).stdout.decode(),flush=True)
adb('shell','am','force-stop',PKG)
adb('shell','run-as',PKG,'mkdir','-p','files')
adb('shell','run-as',PKG,'rm','-f','files/qa-result.json')
assert MODE in ('solo','client')
trigger="printf '%s\\n' "+shlex.quote(MODE)+" > files/qa_mode.txt"
adb('shell','run-as '+PKG+' sh -c '+shlex.quote(trigger))
host=None
try:
 if MODE=='client':
  host=subprocess.Popen(['godot','--headless','--path',str(ROOT/'puff-crew'),'--','--android-test-host'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True)
 adb('shell','am','start','-n',PKG+'/com.godot.game.GodotAppLauncher')
 result=None
 for _ in range(100):
  raw=private_read('qa-result.json')
  if raw.returncode==0:
   try: result=json.loads(raw.stdout)
   except json.JSONDecodeError: pass
   if result is not None: break
  time.sleep(.5)
 if result is None:
  print(adb('logcat','-d','-s','godot:V','AndroidRuntime:E').stdout.decode()[-7000:])
  raise RuntimeError('Android QA timed out')
 (OUT/f'android-{MODE}-qa.json').write_text(json.dumps(result,indent=2)+'\n')
 for name in ['menu','gameplay' if MODE=='solo' else 'coop','privacy','wardrobe','outfit-gameplay']:
  shot=private_read('qa-'+name+'.png')
  if shot.returncode==0: (OUT/f'android-{name}.png').write_bytes(shot.stdout)
 print(json.dumps(result,indent=2),flush=True)
 passed=bool(result.get('pass'))
 if host is not None:
  output,_=host.communicate(timeout=40)
  (OUT/'android-desktop-host.log').write_text(output)
  print(output,flush=True)
  passed=passed and host.returncode==0 and 'PASS' in output and 'SCRIPT ERROR' not in output
 raise SystemExit(0 if passed else 1)
finally:
 if host is not None and host.poll() is None:
  host.terminate()
  try: host.wait(timeout=5)
  except subprocess.TimeoutExpired: host.kill();host.wait()
