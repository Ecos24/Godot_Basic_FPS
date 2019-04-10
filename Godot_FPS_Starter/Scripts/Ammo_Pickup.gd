extends Spatial

# The size of the health pickup. Notice how we’re using a setget function
# to tell if it’s changed.
export (int, "full size", "small") var kit_size = 0 setget kit_size_change

# The amount of health each pickup in each size contains.
# 0 = full size pickup, 1 = small pickup
const AMMO_AMOUNTS = [4, 1]
# The amount of grenades each pickup contains.
const GRENADE_AMOUNTS = [2,1]

# The amount of time, in seconds, it takes for the health pickup to respawn.
const RESPAWN_TIME = 20
# A variable used to track how long the health pickup has been waiting to respawn.
var respawn_timer = 0

# A variable to track whether the _ready function has been called or not.
var is_ready = false
# We’re using is_ready because setget functions are called before _ready;
# we need to ignore the first kit_size_change call, because we cannot
# access child nodes until _ready is called. If we did not ignore the
# first setget call, we would get several errors in the debugger.

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the body_entered signal from the Health_Pickup_Trigger
	# to the trigger_body_entered function.
	$Holder/Ammo_Pickup_Trigger.connect("body_entered", self, "trigger_body_entered")
	
	# Set is_ready to true so we can use the setget function.
	is_ready = true
	
	# Hide all the possible kits and their collision shapes using kit_size_change_values.
	kit_size_change_values(0, false)
	kit_size_change_values(1, false)
	# Make only the kit size we selected visible, calling kit_size_change_values
	# and passing in kit_size and true, so the size at kit_size is enabled.
	kit_size_change_values(kit_size, true)

func _physics_process(delta):
	if respawn_timer > 0:
		respawn_timer -= delta
		
		if respawn_timer <= 0:
			kit_size_change_values(kit_size, true)

func kit_size_change(value):
	if is_ready:
		kit_size_change_values(kit_size, false)
		kit_size = value
		kit_size_change_values(kit_size, true)
	else:
		kit_size = value

func kit_size_change_values(size, enable):
	if size == 0:
		$Holder/Ammo_Pickup_Trigger/Shape_Kit.disabled = !enable
		$Holder/Ammo_Kit.visible = enable
	elif size == 1:
		$Holder/Ammo_Pickup_Trigger/Shape_Kit_Small.disabled = !enable
		$Holder/Ammo_Kit_Small.visible = enable

func trigger_body_entered(body):
	if body.has_method("add_ammo"):
		body.add_ammo(AMMO_AMOUNTS[kit_size])
		respawn_timer = RESPAWN_TIME
		kit_size_change_values(kit_size, false)
	if body.has_method("add_grenade"):
		body.add_grenade(GRENADE_AMOUNTS[kit_size])
		respawn_timer = RESPAWN_TIME
		kit_size_change_values(kit_size, false)