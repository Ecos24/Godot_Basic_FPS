extends Spatial

# The speed at which the bullet travels.
var BULLET_SPEED = 70
# The damage the bullet will cause to anything with which it collides.
var BULLET_DAMAGE = 15

# How long the bullet can last without hitting anything.
const KILL_TIMER = 4
# A float for tracking how long the bullet has been alive.
var timer = 0

# A boolean for tracking whether or not we’ve hit something.
var hit_something = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area.connect("body_entered", self, "collided")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var forward_dir = global_transform.basis.z.normalized()
	global_translate(forward_dir * BULLET_SPEED * delta)
	
	timer += delta
	if timer >= KILL_TIMER:
		queue_free()

func collided(body):
	if hit_something == false:
		if body.has_method("bullet_hit"):
			body.bullet_hit(BULLET_DAMAGE, global_transform)
	
	hit_something = true
	queue_free()