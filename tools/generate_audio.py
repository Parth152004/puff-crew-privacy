"""Generate original, editable PCM effects and a quiet eight-bar river loop."""
from pathlib import Path
import math,random,struct,wave
OUT=Path(__file__).resolve().parents[1]/'puff-crew/assets/audio'
OUT.mkdir(exist_ok=True)
RATE=22050

def save(name,samples,loop=False):
 with wave.open(str(OUT/f'{name}.wav'),'wb') as w:
  w.setnchannels(1);w.setsampwidth(2);w.setframerate(RATE)
  w.writeframes(b''.join(struct.pack('<h',int(max(-1,min(1,s))*32767)) for s in samples))

for kind,duration in [('puff',.22),('tap',.06),('checkpoint',.6),('splash',.4),('finish',1.3)]:
 rng=random.Random(7331);phase=0;samples=[]
 for i in range(int(RATE*duration)):
  t=i/RATE;u=t/duration
  if kind=='puff':
   phase+=math.tau*(140-80*u)/RATE
   v=(math.sin(phase)+math.sin(phase*2.01)*.4+rng.uniform(-.28,.28))*math.sin(math.pi*u)*.35
  elif kind=='tap':v=math.sin(t*math.tau*720)*math.exp(-u*7)*.3
  elif kind=='splash':v=rng.uniform(-1,1)*math.sin(math.pi*u)*math.exp(-u*3)*.6
  else:
   notes=[523.25,659.25,783.99] if kind=='checkpoint' else [523.25,659.25,783.99,1046.5]
   note=notes[min(int(u*len(notes)),len(notes)-1)]
   v=(math.sin(t*math.tau*note)+.1*math.sin(t*math.tau*note*2))*math.sin(math.pi*((u*len(notes))%1))*.24
  samples.append(v)
 save(kind,samples)
# Four simple major-sixth chords, with an original sparse pentatonic figure.
length=16.0
notes=[72,None,76,None,79,76,None,74,69,None,72,None,76,74,None,None,67,None,71,None,74,71,None,69,65,None,69,None,72,69,None,None]
chords=[(48,55,64),(45,52,60),(43,50,59),(41,48,57)]
rng=random.Random(190);filtered=0;samples=[]
for i in range(int(RATE*length)):
 t=i/RATE;chord=chords[min(3,int(t/4))]
 pad=sum(math.sin(math.tau*440*2**((n-69)/12)*t) for n in chord)*.025
 step=int(t/.5);note=notes[step];age=t-step*.5
 pluck=0 if note is None else math.sin(math.tau*440*2**((note-69)/12)*age)*math.exp(-age*8)*.09
 filtered=.97*filtered+.03*rng.uniform(-1,1)
 water=filtered*.11*(.75+.25*math.sin(t*math.tau/4))
 envelope=min(1,t/.15,(length-t)/.15)
 samples.append((pad+pluck+water)*envelope)
save('river_loop',samples)
print('Generated',len(list(OUT.glob('*.wav'))),'original WAV assets')
