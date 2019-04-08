extends KinematicBody

# How strong gravity pulls us down.
const GRAVITY = -24.8
# Our KinematicBody’s velocity.
var vel = Vector3()
# The fastest speed we can reach. Once we hit this speed, we will not go any faster.
const MAX_SPEED = 20
# How high we can jump.
const JUMP_SPEED = 18
# How quickly we accelerate. The higher the value, the sooner we get to max speed.
const ACCEL = 4.5
# How quickly we are going to decelerate. The higher the value,
# the sooner we will come to a complete stop.
const DEACCEL = 16

# Sprinting Variables
const MAX_SPRINT_SPEED = 30
const SPRINT_ACCEL = 18
var is_sprinting = false

# This is a variable we will be using to hold the player’s flash light node.
var flashlight
var is_flashlightOn = true

var dir = Vector3()

# The steepest angle our KinematicBody will consider as a ‘floor’.
const MAX_SLOPE_ANGLE = 40

# The Camera node.
var camera
# A Spatial node holding everything we want to rotate on the X axis (up and down).
var rotation_helper

# How sensitive the mouse is. I find a value of 0.05 works well for my mouse,
# but you may need to change it based on how sensitive your mouse is.
var MOUSE_SENSITIVITY = 0.1

# This will hold the AnimationPlayer node and its script, which we wrote previously.
var animation_manager

# The name of the weapon we are currently using.
var current_weapon_name = "UNARMED"
# A dictionary that will hold all the weapon nodes.
var weapons = {"UNARMED":null, "KNIFE":null, "PISTOL":null, "RIFLE":null}
# A dictionary allowing us to convert from a weapon’s number to its name.
# We’ll use this for changing weapons.
const WEAPON_NUMBER_TO_NAME = {0:"UNARMED", 1:"KNIFE", 2:"PISTOL", 3:"RIFLE"}
# A dictionary allowing us to convert from a weapon’s name to its number.
# We’ll use this for changing weapons.
const WEAPON_NAME_TO_NUMBER = {"UNARMED":0, "KNIFE":1, "PISTOL":2, "RIFLE":3}
# A boolean to track whether or not we are changing guns/weapons.
var changing_weapon = false
# The name of the weapon we want to change to.
var changing_weapon_name = "UNARMED"

# A variable to track whether or not the player is currently trying to reload.
var reloading_weapon = false

# How much health our player has.
var health = 100

# A label to show how much health we have, and how much ammo we have both in
# our gun and in reserve.
var UI_status_label

# Variable to hold the Simple Audio Player resources.
var simple_audio_player = preload("res://Simple_Audio_Player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Getting Elements in variable
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper
	
	# we get the AnimationPlayer node and assign it to the animation_manager variable.
	animation_manager = $Rotation_Helper/Model/Animation_Player
	# set the callback function to a FuncRef that will call the player’s
	# fire_bullet function.
	animation_manager.callback_function = funcref(self, "fire_bullet")
	
	# Setting Mouse as input mode
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Get all the weapon nodes and assign them to weapons.
	weapons["KNIFE"] = $Rotation_Helper/Gun_Fire_Points/Knife_Point
	weapons["PISTOL"] = $Rotation_Helper/Gun_Fire_Points/Pistol_Point
	weapons["RIFLE"] = $Rotation_Helper/Gun_Fire_Points/Rifle_Point
	
	# Get Gun_Aim_Point’s global position so we can rotate the player’s weapons
	# to aim at it.
	var gun_aim_point_pos = $Rotation_Helper/Gun_Aim_Point.global_transform.origin
	
	for weapon in weapons:
		var weapon_node = weapons[weapon]
		if weapon_node != null:
			# Set its player_node variable to this script (Player.gd)
			weapon_node.player_node = self
			
			weapon_node.look_at(gun_aim_point_pos, Vector3(0,1,0))
			weapon_node.rotate_object_local(Vector3(0,1,0), deg2rad(180))
	
	current_weapon_name = "UNARMED"
	changing_weapon_name = "UNARMED"
	
	UI_status_label = $HUD/Panel/Gun_label
	flashlight = $Rotation_Helper/Flashlight

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	process_changing_weapons(delta)
	process_reloading(delta)
	process_UI(delta)

#warning-ignore:unused_argument
func process_input(delta):
	#------------------------------------------------------------------
	#---------------------------- WALKING -----------------------------
	# Will be used for storing the direction the player intends to move towards.
	# Because we do not want the player’s previous input to effect the player beyond
	# a single process_movement call, we reset dir.
	dir = Vector3()
	var cam_xfrom = camera.get_global_transform()
	
	var input_movement_vector = Vector2()
	
	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.y += 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.y -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	
	input_movement_vector = input_movement_vector.normalized()
	
	dir += -cam_xfrom.basis.z.normalized() * input_movement_vector.y
	dir += cam_xfrom.basis.x.normalized() * input_movement_vector.x
	#------------------------------------------------------------------
	
	#------------------------------------------------------------------
	#---------------------------- JUMPING -----------------------------
	if is_on_floor():
		if Input.is_action_pressed("movement_jump"):
			vel.y = JUMP_SPEED
	#------------------------------------------------------------------
	
	#------------------------------------------------------------------
	#---------------- Capturing/Freeing the cursor --------------------
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#------------------------------------------------------------------
	
	#------------------------------------------------------------------
	#--------------------------- SPRINTING ----------------------------
	if Input.is_action_pressed("movement_sprint"):
		is_sprinting = true
	else:
		is_sprinting = false
	#------------------------------------------------------------------
	
	#------------------------------------------------------------------
	#------------------- Truning Flashlight ON/OFF --------------------
	if Input.is_action_just_pressed("flashlight"):
		if is_flashlightOn:
			flashlight.hide()
			is_flashlightOn = false
		else:
			flashlight.show()
			is_flashlightOn = true
	#------------------------------------------------------------------
	
	#------------------------------------------------------------------
	#----------------------- Changing Weapons -------------------------
	# Get the current weapon’s number and assign it to weapon_change_number.
	var weapon_change_number = WEAPON_NAME_TO_NUMBER[current_weapon_name]
	
	if Input.is_key_pressed(KEY_1):
		weapon_change_number = 0
	if Input.is_key_pressed(KEY_2):
		weapon_change_number = 1
	if Input.is_key_pressed(KEY_3):
		weapon_change_number = 2
	if Input.is_key_pressed(KEY_4):
		weapon_change_number = 3
	
	if Input.is_action_just_pressed("shift_weapon_positive"):
		weapon_change_number += 1
	if Input.is_action_just_pressed("shift_weapon_negative"):
		weapon_change_number -= 1
	
	weapon_change_number = clamp(weapon_change_number, 0, WEAPON_NAME_TO_NUMBER.size() - 1)
	
	if changing_weapon == false:
		if reloading_weapon == false:
			if WEAPON_NUMBER_TO_NAME[weapon_change_number] != current_weapon_name:
				changing_weapon_name = WEAPON_NUMBER_TO_NAME[weapon_change_number]
				changing_weapon = true
	#------------------------------------------------------------------
	
	#------------------------------------------------------------------
	#------------------------- Firing Weapon --------------------------
	if Input.is_action_pressed("fire"):
		if reloading_weapon == false:
			if changing_weapon == false:
				var current_weapon = weapons[current_weapon_name]
				if current_weapon != null:
					if current_weapon.ammo_in_weapon > 0:
						if animation_manager.current_state == current_weapon.IDLE_ANIM_NAME:
							animation_manager.set_animation(current_weapon.FIRE_ANIM_NAME)
					else:
						reloading_weapon = true
	#------------------------------------------------------------------
	
	#------------------------------------------------------------------
	#--------------------------- RELOADING ----------------------------
	if reloading_weapon == false:
		if changing_weapon == false:
			if Input.is_action_just_pressed("reload"):
				var current_weapon = weapons[current_weapon_name]
				if current_weapon != null:
					if current_weapon.CAN_RELOAD == true:
						var current_anim_state = animation_manager.current_state
						var is_reloading = false
						for weapon in weapons:
							var weapon_node = weapons[weapon]
							if weapon_node != null:
								if current_anim_state == weapon_node.RELOADING_ANIM_NAME:
									is_reloading = true
						if is_reloading == false:
							reloading_weapon = true
	#------------------------------------------------------------------

func process_movement(delta):
	dir.y = 0
	# We normalize dir to ensure we’re within a 1 radius unit circle.
	dir = dir.normalized()
	
	# We add gravity to the player.
	vel.y += delta * GRAVITY
	
	var hvel = vel
	hvel.y = 0
	
	var target = dir
	# We multiply that by the player’s max speed so we know how far the player
	# will move in the direction provided by dir.
	if is_sprinting:
		target *= MAX_SPRINT_SPEED
	else:
		target *= MAX_SPEED
	
	var accel
	# We then take the dot product of hvel to see if the player is moving
	# according to hvel. Remember, hvel does not have any Y velocity,
	# meaning we are only checking if the player is moving forwards, backwards,
	# left, or right.
	if dir.dot(hvel) > 0:
		if is_sprinting:
			accel = SPRINT_ACCEL
		else:
			accel = ACCEL
	else:
		accel = DEACCEL
	
	hvel = hvel.linear_interpolate(target, accel*delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0,1,0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func process_changing_weapons(delta):
	# The first thing we do is make sure we’ve received input to change weapons.
	# We do this by making sure changing_weapons is true.
	if changing_weapon == true:
		# To check whether the current weapon has been successfully unequipped or not.
		var weapon_unequipped = false
		# Get the current weapon from weapons.
		var current_weapon = weapons[current_weapon_name]
		
		if current_weapon == null:
			weapon_unequipped = true
		else:
			if current_weapon.is_weapon_enabled == true:
				weapon_unequipped = current_weapon.unequip_weapon()
			else:
				weapon_unequipped = true
		
		if weapon_unequipped == true:
			var weapon_equipped = false
			var weapon_to_equip = weapons[changing_weapon_name]
			
			if weapon_to_equip == null:
				weapon_equipped = true
			else:
				if weapon_to_equip.is_weapon_enabled == false:
					weapon_equipped == weapon_to_equip.equip_weapon()
				else:
					weapon_equipped = true
			
			if weapon_equipped == true:
				changing_weapon = false
				current_weapon_name = changing_weapon_name
				changing_weapon_name = ""

func process_UI(delta):
	if current_weapon_name == "UNARMED" or current_weapon_name == "KNIFE":
		UI_status_label.text = "HEALTH: " + str(health)
	else:
		var current_weapon = weapons[current_weapon_name]
		UI_status_label.text = "HEALTH: " + str(health) + \
		"\nAMMO: " + str(current_weapon.ammo_in_weapon) + \
		"/" + str(current_weapon.spare_ammo)

func process_reloading(delta):
	if reloading_weapon == true:
		var current_weapon = weapons[current_weapon_name]
		if current_weapon != null:
			current_weapon.reload_weapon()
		reloading_weapon = false

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))
	
	var camera_rot = rotation_helper.rotation_degrees
	camera_rot.x = clamp(camera_rot.x, -70, 70)
	rotation_helper.rotation_degrees = camera_rot

# This function will be called by AnimationManager at key points defined in Animation.
func fire_bullet():
	if changing_weapon == true:
		return
	
	weapons[current_weapon_name].fire_weapon()

func create_sound(sound_name, position=null):
	var audio_clone = simple_audio_player.instance()
	var scene_root = get_tree().root.get_child(0)
	scene_root.add_child(audio_clone)
	audio_clone.play_sound(sound_name, position)

