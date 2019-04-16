extends Spatial

const DAMAGE = 4

# The name of the rifle's idle animation.
const IDLE_ANIM_NAME = "Rifle_idle"
# The name of the rifle's fire animation.
const FIRE_ANIM_NAME = "Rifle_fire"
# The name of the reloading animation for this weapon.
const RELOADING_ANIM_NAME = "Rifle_reload"

# The amount of ammo currently in the pistol
var ammo_in_weapon = 50
# The amount of ammo we have left in reserve for the pistol
var spare_ammo = 100
# The amount of ammo in a fully reloaded weapon/magazine
const AMMO_IN_MAG = 50

# A boolean to track whether this weapon has the ability to reload
const CAN_RELOAD = true
# A boolean to track whether we can refill this weapon’s spare ammo.
const CAN_REFILL = true

var is_weapon_enabled = false

var player_node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func fire_weapon():
	var ray = $Ray_Cast
	# This will force the Raycast to detect collisions when we call it,
	# meaning we get a frame perfect collision check with the 3D physics world.
	ray.force_raycast_update()
	
	if ray.is_colliding():
		var body = ray.get_collider()
		
		if body == player_node:
			pass
		elif body.has_method("bullet_hit"):
			body.bullet_hit(DAMAGE, ray.global_transform)
	
	# Reduce ammo for each fire.
	ammo_in_weapon -= 1
	
	# Play Firing sound.
	player_node.create_sound("Rifle_shot", false, ray.global_transform.origin)

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
		player_node.create_sound("Gun_cock", false, player_node.camera.global_transform.origin)
		
		return true
	
	return false

func equip_weapon():
	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
		is_weapon_enabled = true
		return true
	
	if player_node.animation_manager.current_state == "Idle_unarmed":
		player_node.animation_manager.set_animation("Rifle_equip")
	
	return false

func unequip_weapon():
	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
		if player_node.animation_manager.current_state != "Rifle_unequip":
			player_node.animation_manager.set_animation("Rifle_unequip")
	
	if player_node.animation_manager.current_state == "Idle_unarmed":
		is_weapon_enabled = false
		return true
	
	return false

func reset_weapon():
	ammo_in_weapon = AMMO_IN_MAG
	spare_ammo =  100