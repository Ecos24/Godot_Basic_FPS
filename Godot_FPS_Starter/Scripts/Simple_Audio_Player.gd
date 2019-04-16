extends Spatial

var audio_node = null
var should_loop = false
var globals = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get the AudioStreamPlayer
	audio_node = $Audio_Stream_Player
	# Connect its finished signal to the destroy_self function.
	audio_node.connect("finished", self, "sound_finished")
	# To make sure it is not playing any sounds, we call stop on the AudioStreamPlayer.
	audio_node.stop()
	
	globals = get_node("/root/Globals")

func play_sound(audio_stream, position=null):
	if audio_stream == null:
		print("No audio stream passed. Cannot play sound")
		globals.created_audio.remove(globals.created_audio.find(self))
		queue_free()
		return
	
	audio_node.stream = audio_stream
	
	# Setting position for 3D audio
	if audio_node is AudioStreamPlayer3D:
		if position != null:
			audio_node.global_transform.origin = position
	
	audio_node.play(0.0)

func sound_finished():
	if should_loop:
		audio_node.play(0.0)
	else:
		globals.created_audio.remove(globals.created_audio.find(self))
		audio_node.stop()
		queue_free()