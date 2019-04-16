extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	var globals = get_node("/root/Globals")
	globals.respawn_points = get_children()