extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$OS_Label.text = "OS: " + OS.get_name()
	$Engine_Label.text = "Godot version: " + Engine.get_version_info()["string"]

func _process(delta):
	$FPS_Label.text = "FPS: " + str(Engine.get_frames_per_second())