extends AnimationPlayer

# Structure -> Animation name : [Connecting Animation states]
# A dictionary for holding our animation states.
var states = {
	"Idle_unarmed": ["Knife_equip", "Pistol_equip", "Rifle_equip", "Idle_unarmed"],
	
	"Pistol_equip": ["Pistol_idle"],
	"Pistol_fire": ["Pistol_idle"],
	"Pistol_idle": ["Pistol_fire", "Pistol_reload", "Pistol_unequip", "Pistol_idle"],
	"Pistol_reload": ["Pistol_idle"],
	"Pistol_unequip": ["Idle_unarmed"],
	
	"Rifle_equip": ["Rifle_idle"],
	"Rifle_fire": ["Rifle_idle"],
	"Rifle_idle": ["Rifle_fire", "Rifle_reload", "Rifle_unequip", "Rifle_idle"],
	"Rifle_reload": ["Rifle_idle"],
	"Rifle_unequip": ["Idle_unarmed"],
	
	"Knife_equip": ["Knife_idle"],
	"Knife_fire": ["Knife_idle"],
	"Knife_idle": ["Knife_fire", "Knife_unequip", "Knife_idle"],
	"Knife_unequip": ["Idle_unarmed"]
}

# A dictionary for holding all the speeds at which we want to play our animations.
var animation_speed = {
	"Idle_unarmed": 1,
	
	"Pistol_equip": 1.4,
	"Pistol_fire": 1.8,
	"Pistol_idle": 1,
	"Pistol_reload": 1,
	"Pistol_unequip": 1.4,
	
	"Rifle_equip": 2,
	"Rifle_fire": 6,
	"Rifle_idle": 1,
	"Rifle_reload": 1.45,
	"Rifle_unequip": 2,
	
	"Knife_equip": 1,
	"Knife_fire": 1.35,
	"Knife_idle": 1,
	"Knife_unequip": 1
}

# A variable for holding the name of the animation state we are currently in.
var current_state = null
# A variable for holding the callback function.
# This will be a FuncRef passed in by the player for spawning bullets at the proper
# frame of animation. A FuncRef allows us to pass in a function as an argument,
# effectively allowing us to call a function from another script,
# which is how we will use it later.
var callback_function = null

# Called when the node enters the scene tree for the first time.
func _ready():
	set_animation("Idle_unarmed")
	# Connects a signal to a method on a target object.
	connect("animation_finished", self, "animation_ended")

func set_animation(animation_name):
	if animation_name == current_state:
		print("AnimationPlayer_Manager.gd -- WARNING: animation is already ", animation_name)
		return true
	
	if has_animation(animation_name):
		if current_state != null:
			var possible_animations = states[current_state]
			if animation_name in possible_animations:
				current_state = animation_name
				play(animation_name, -1, animation_speed[animation_name])
				return true
			else:
				print("AnimationPlayer_Manager.gd -- WARNING: Cannot change to ",
				animation_name, " from ", current_state)
				return false
		else:
			current_state = animation_name
			# Blend time is how long to blend/mix the two animations together.
			# By putting in a value of -1, the new animation instantly plays,
			# overriding whatever animation is already playing.
			play(animation_name, -1, animation_speed[animation_name])
			return true
	return false

func animation_ended(anim_name):
	
	#Unarmed transitions
	if current_state == "Idle_unarmed":
		pass
	# Knife transitions
	elif current_state == "Knife_equip":
		set_animation("Knife_idle")
	elif current_state == "Knife_idle":
		pass
	elif current_state == "Knife_fire":
		set_animation("Knife_idle")
	elif current_state == "Knife_unequip":
		set_animation("Idle_unarmed")
	# Pistol transitions
	elif current_state == "Pistol_equip":
		set_animation("Pistol_idle")
	elif current_state == "Pistol_idle":
		pass
	elif current_state == "Pistol_fire":
		set_animation("Pistol_idle")
	elif current_state == "Pistol_unequip":
		set_animation("Idle_unarmed")
	elif current_state == "Pistol_reload":
		set_animation("Pistol_idle")
	# Rifle transitions
	elif current_state == "Rifle_equip":
		set_animation("Rifle_idle")
	elif current_state == "Rifle_idle":
		pass
	elif current_state == "Rifle_fire":
		set_animation("Rifle_idle")
	elif current_state == "Rifle_unequip":
		set_animation("Idle_unarmed")
	elif current_state == "Rifle_reload":
		set_animation("Rifle_idle")

# This function will be called by a function track in our animations.
func animation_callback():
	if callback_function == null:
		print("AnimationPlayer_Manager.gd -- WARNING: No callback function for the animation to call!")
	else:
		callback_function.call_func()