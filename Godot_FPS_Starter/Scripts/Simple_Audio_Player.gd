extends Spatial

# All of the audio files.
var pistol_shot = preload("res://assets/Gun Sound Pack/gun_revolver_pistol_shot_04.wav")
var gun_cock = preload("res://assets/Gun Sound Pack/gun_semi_auto_rifle_cock_02.wav")
var rifle_shot = preload("res://assets/Gun Sound Pack/gun_rifle_sniper_shot_01.wav")

var audio_node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Get the AudioStreamPlayer
	audio_node = $Audio_Stream_Player
	# Connect its finished signal to the destroy_self function.
	audio_node.connect("finished", self, "destroy_self")
	# To make sure it is not playing any sounds, we call stop on the AudioStreamPlayer.
	audio_node.stop()

func play_sound(sound_name, position=null):
	if pistol_shot == null or rifle_shot == null or gun_cock == null:
		print("Audio not set!")
		queue_free()
		return
	
	if sound_name == "Pistol_shot":
		audio_node.stream = pistol_shot
	elif sound_name == "Rifle_shot":
		audio_node.stream = rifle_shot
	elif sound_name == "Gun_cock":
		audio_node.stream = gun_cock
	else:
		print("UNKNOWN STREAM")
		queue_free()
		return
	
	# Setting position for 3D audio
	if audio_node is AudioStreamPlayer3D:
		if position != null:
			audio_node.global_transform.origin = position
	
	audio_node.play()

func destroy_self():
	audio_node.stop()
	queue_free()