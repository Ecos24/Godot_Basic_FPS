extends RigidBody

# The amount of damage the grenade causes when it explodes.
const GRENADE_DAMAGE = 40

# The amount of time the grenade takes (in seconds) to
# explode once it’s created/thrown.
const GRENADE_TIME = 3
# A variable for tracking how long the grenade has been created/thrown.
var grenade_timer = 0

# The amount of time needed (in seconds) to wait before we destroy
# the grenade scene after the explosion
const EXPLOSION_WAIT_TIME = 0.48
# A variable for tracking how much time has passed since the grenade exploded.
var explosion_wait_timer = 0

# A variable for tracking whether or not the sticky grenade has
# attached to a PhysicsBody.
var attached = false
# A variable to hold a Spatial that will be at the position where
# the sticky grenade collided.
var attach_point = null

# The CollisionShape for the grenade’s RigidBody.
var rigid_shape
# The MeshInstance for the grenade.
var grenade_mesh
# The blast Area used to damage things when the grenade explodes.
var blast_area
# The Particles that come out when the grenade explodes.
var explosion_particles

# The player’s KinematicBody.
var player_body

# Called when the node enters the scene tree for the first time.
func _ready():
	rigid_shape = $Collision_Shape
	grenade_mesh = $Sticky_Grenade
	blast_area = $Blast_Area
	explosion_particles = $Explosion
	
	explosion_particles.emitting = false
	explosion_particles.one_shot = true
	
	$Sticky_Area.connect("body_entered", self, "collided_with_body")

func collided_with_body(body):
	if body == self:
		return
	
	if player_body != null:
		if body == player_body:
			return
	
	if attached == false:
		attached = true
		attach_point = Spatial.new()
		body.add_child(attach_point)
		attach_point.global_transform.origin = global_transform.origin
		
		rigid_shape.disabled = true
		
		mode = RigidBody.MODE_STATIC

func _process(delta):
	if attached == true:
		if attach_point != null:
			global_transform.origin = attach_point.global_transform.origin
	
	if grenade_timer < GRENADE_TIME:
		grenade_timer += delta
		return
	else:
		if explosion_wait_timer <= 0:
			explosion_particles.emitting = true
			
			grenade_mesh.visible = false
			rigid_shape.disabled = true
			
			mode = RigidBody.MODE_STATIC
			
			var bodies = blast_area.get_overlapping_bodies()
			for body in bodies:
				if body.has_method("bullet_hit"):
					body.bullet_hit(GRENADE_DAMAGE, body.global_transform.looking_at(global_transform.origin, Vector3(0,1,0)))
			
			# This would be the perfect place to play a sound!
		
		if explosion_wait_timer < EXPLOSION_WAIT_TIME:
			explosion_wait_timer += delta
			
			if explosion_wait_timer >= EXPLOSION_WAIT_TIME:
				if attach_point != null:
					attach_point.queue_free()
				queue_free()