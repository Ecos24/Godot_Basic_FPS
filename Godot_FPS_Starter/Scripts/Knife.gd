extends Spatial

const DAMAGE = 40

# The name of the Knife's idle animation.
const IDLE_ANIM_NAME = "Knife_idle"
# The name of the Knife's fire animation.
const FIRE_ANIM_NAME = "Knife_fire"
# The name of the reloading animation for this weapon.
const RELOADING_ANIM_NAME = ""

var is_weapon_enabled = false

# The amount of ammo currently in the pistol
var ammo_in_weapon = 1
# The amount of ammo we have left in reserve for the pistol
var spare_ammo = 1
# The amount of ammo in a fully reloaded weapon/magazine
const AMMO_IN_MAG = 1

# A boolean to track whether this weapon has the ability to reload
const CAN_RELOAD = false
# A boolean to track whether we can refill this weapon’s spare ammo.
const CAN_REFILL = false

var player_node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func fire_weapon():
	# Get the Area child node of Knife_Point.
	var area = $Area
	# This will return a list of every body that touches the Area.
	var bodies = area.get_overlapping_bodies()
	
	for body in bodies:
		if body == player_node:
			continue
		
		if body.has_method("bullet_hit"):
			body.bullet_hit(DAMAGE, area.global_transform)

func reload_weapon():
	return false

func equip_weapon():
	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
		is_weapon_enabled = true
		return true
	
	if player_node.animation_manager.current_state == "Idle_unarmed":
		player_node.animation_manager.set_animation("Knife_equip")
	
	return false

func unequip_weapon():
	if player_node.animation_manager.current_state == IDLE_ANIM_NAME:
		player_node.animation_manager.set_animation("Knife_unequip")
	
	if player_node.animation_manager.current_state == "Idle_unarmed":
		is_weapon_enabled = false
		return true
	
	return false

func reset_weapon():
	ammo_in_weapon = 1
	spare_ammo =  1