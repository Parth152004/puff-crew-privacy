class_name CrewAudio
extends Node
var game: Node
var pool: Array[AudioStreamPlayer] = []
var sounds: Dictionary = {}
var cursor: int = 0
var ambience: AudioStreamPlayer

func _ready() -> void:
 if DisplayServer.get_name()=="headless":
  set_process(false)
  return
 for i in range(6):
  var p=AudioStreamPlayer.new()
  p.volume_db=-12
  add_child(p)
  pool.append(p)
 for kind in ["puff","tap","checkpoint","splash","finish"]:
  sounds[kind]=load("res://assets/audio/"+kind+".wav")
 ambience=AudioStreamPlayer.new()
 var loop: AudioStreamWAV=load("res://assets/audio/river_loop.wav").duplicate()
 loop.loop_mode=AudioStreamWAV.LOOP_FORWARD
 loop.loop_begin=0
 loop.loop_end=int(loop.get_length()*loop.mix_rate)
 ambience.stream=loop
 ambience.volume_db=-17
 add_child(ambience)
 ambience.play()

func _process(_dt: float) -> void:
 if ambience!=null and game!=null: ambience.stream_paused=not game.sound_on

func play_cue(kind: String) -> void:
 if game==null or not game.sound_on or pool.is_empty() or not sounds.has(kind): return
 var p=pool[cursor%pool.size()]
 cursor+=1
 p.stream=sounds[kind]
 p.play()

func shutdown() -> void:
 if is_instance_valid(ambience):
  ambience.stop()
  ambience.stream=null
 for player in pool:
  if is_instance_valid(player):
   player.stop()
   player.stream=null
 sounds.clear()

func _exit_tree() -> void:
 shutdown()
