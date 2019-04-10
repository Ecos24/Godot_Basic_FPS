extends StaticBody

# The amount of damage needed to break a fully healed target.
const TARGET_HEALTH = 40
# The amount of health this target currently has.
var current_health = TARGET_HEALTH

# A variable to hold the Broken_Target_Holder node so we can use it easily.
var broken_target_holder

# The collision shape for the target.
# NOTE: This is for the whole target, not the pieces of the target
# A variable to hold the CollisionShape for the non-broken target.
var target_collision_shape

# The length of time, in seconds, it takes for a target to respawn.
const TARGET_RESPAWN_TIME = 14
# A variable to track how long a target has been broken.
var target_respawn_timer = 0

# A PackedScene to hold the broken target scene.
export (PackedScene) var destroyed_target

# Called when the node enters the scene tree for the first time.
func _ready():
	broken_target_holder = $"../Broken_Target_Holder"
	target_collision_shape = $Collision_Shape

func _physics_process(delta):
	if target_respawn_timer > 0:
		target_respawn_timer -= delta
		
		if target_respawn_timer <= 0:
			for child in broken_target_holder.get_children():
				child.queue_free()
			
			target_collision_shape.disabled = false
			visible = true
			current_health = TARGET_HEALTH

func bullet_hit(damage, bullet_transform):
	current_health -= damage
	
	if current_health <= 0:
		var clone = destroyed_target.instance()
		broken_target_holder.add_child(clone)
		
		for rigid in clone.get_children():
			if rigid is RigidBody:
				var center_in_rigid_space = broken_target_holder.global_transform.origin - rigid.global_transform.origin
				var direction = (rigid.transform.origin - center_in_rigid_space).normalized()
				# Apply the impulse with some additional force
				rigid.apply_impulse(center_in_rigid_space, direction * 12 * damage)
		
		target_respawn_timer = TARGET_RESPAWN_TIME
		
		target_collision_shape.disabled = true
		visible = false