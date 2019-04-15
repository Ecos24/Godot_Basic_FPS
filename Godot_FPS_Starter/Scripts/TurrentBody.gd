extends StaticBody

export (NodePath) var path_to_turrent_root

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func bullet_hit(damage, bullet_hit_pos):
	if path_to_turrent_root != null:
		get_node(path_to_turrent_root).bullet_hit(damage, bullet_hit_pos)