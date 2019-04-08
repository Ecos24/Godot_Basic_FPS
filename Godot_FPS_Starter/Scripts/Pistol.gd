extends Spatial

# The reason we define most of these variables is so we can use them in Player.gd.
# The amount of damage a single bullet does.
const DAMAGE = 15
# The name of the pistol’s idle animation.
const IDLE_ANIM_NAME = "Pistol_idle"
# The name of the pistol’s fire animation.
const FIRE_ANIM_NAME = "Pistol_fire"
# The name of the reloading animation for this weapon.
const RELOADING_ANIM_NAME = "Pistol_reload"

# A variable for checking whether this weapon is in use/enabled.
var is_weapon_enabled = false

# The amount of ammo currently in the pistol
var ammo_in_weapon = 10
# The amount of ammo we have left in reserve for the pistol
var spare_ammo = 20
# The amount of ammo in a fully reloaded weapon/magazine
const AMMO_IN_MAG = 10

# A boolean to track whether this weapon has the ability to reload
const CAN_RELOAD = true
# A boolean to track whether we can refill this weapon’s spare ammo.
const CAN_REFILL = true

# The bullet scene we worked on earlier.
var bullet_scene = preload("res://Bullet_Scene.tscn")

# A variable to hold Player.gd.
var player_node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func fire_weapon():
	# we are adding a clone as a child of the first node (whatever is at the top of
	# the scene tree) in the currently loaded/opened scene.
	var clone = bullet_scene.instance()
	var scene_root = get_tree().root.get_child(0)
	scene_root.add_child(clone)
	
	# set the global transform of the clone to the Pistol_Aim_Point’s global transform.
	# The reason we do this is so the bullet is spawned at the end of the pistol.
	clone.global_transform = self.global_transform
	# we scale it up by a factor of 4 because the bullet scene is a little too
	# small by default.
	clone.scale = Vector3(4,4,4)
	# we set the bullet’s damage (BULLET_DAMAGE) to the amount of damage a single
	# pistol bullet does (DAMAGE).
	clone.BULLET_DAMAGE = DAMAGE
	
	# Reduce ammo for each fire.
	ammo_in_weapon -= 1
	
	# Play Firing sound.
	player_node.create_sound("Pistol_shot", self.global_transform.origin)

func reload_weapon():
	var can_reload = false
	
	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
		can_reload = true
	
	if spare_ammo <= 0 or ammo_in_weapon == AMMO_IN_MAG:
		can_reload = false
	
	if can_reload == true:
		var ammo_needed = AMMO_IN_MAG - ammo_in_weapon
		
		if spare_ammo >= ammo_needed:
			spare_ammo -= ammo_needed
			ammo_in_weapon = AMMO_IN_MAG
		else:
			ammo_in_weapon += spare_ammo
			spare_ammo = 0
		
		player_node.animation_manager.set_animation(RELOADING_ANIM_NAME)
		
		# Play reloading sound.
		player_node.create_sound("Gun_cock", player_node.camera.global_transform.origin)
		
		return true
	
	return false

func equip_weapon():
	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
		is_weapon_enabled = true
		return true
	
	if player_node.animation_manager.current_state == "Idle_unarmed":
		player_node.animation_manager.set_animation("Pistol_equip")
	
	return false

func unequip_weapon():
	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
		if player_node.animation_manager.current_state != "Pistol_unequip":
			player_node.animation_manager.set_animation("Pistol_unequip")
	
	if player_node.animation_manager.current_state == "Idle_unarmed":
		is_weapon_enabled = false
		return true
	else:
		return false