extends RigidBody

# We need to boost the directional vector by BASE_BULLET_BOOST
# so the bullets pack a bit more of a punch and move the RigidBody nodes
# in a visible way. You can just set BASE_BULLET_BOOST to lower or higher
# values if you want less or more of a reaction when the bullets collide
# with the RigidBody.
const BASE_BULLET_BOOST = 9

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func bullet_hit(damage, bullet_global_trans):
	# get the bullet’s forward directional vector.
	# This is so we can tell from which direction the bullet will hit the RigidBody.
	# We will use this to push the RigidBody in the same direction as the bullet.
	var direction_vect = bullet_global_trans.basis.z.normalized() * BASE_BULLET_BOOST;
	
	apply_impulse((bullet_global_trans.origin - global_transform.origin).normalized(), direction_vect * damage)