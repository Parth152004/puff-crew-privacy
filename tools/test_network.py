"""Exercise the real ENet host/client protocol in independent Godot processes."""
from pathlib import Path
import subprocess,time,sys
root=Path(__file__).resolve().parents[1]
crew=int(sys.argv[1]) if len(sys.argv)>1 else 2
args=['godot','--headless','--path',str(root/'puff-crew'),'--']
host=subprocess.Popen(args+['--test-host'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True)
time.sleep(.6)
clients=[subprocess.Popen(args+['--test-client'],stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True) for _ in range(crew-1)]
failed=False
for name,process in [('host',host)]+[(f'client-{i+1}',p) for i,p in enumerate(clients)]:
 try: output,_=process.communicate(timeout=20)
 except subprocess.TimeoutExpired:
  process.kill();output,_=process.communicate();failed=True
 (root/'builds'/f'network-{name}.log').write_text(output)
 print(name,output.strip())
 failed=failed or process.returncode!=0 or 'PASS' not in output or 'SCRIPT ERROR' in output or (name=='host' and f'max_crew={crew}' not in output)
sys.exit(1 if failed else 0)
