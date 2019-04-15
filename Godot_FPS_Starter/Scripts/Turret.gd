extends Spatial

# An exported boolean so we can change whether the turret uses objects or 
# raycasting for bullets.
export (bool) var use_raycast = false

# The amount of damage a single bullet scene does.
const TURRENT_DAMAGE_BULLET = 20
# The amount of damage a single Raycast bullet does.
const TURRENT_DAMAGE_RAYCAST = 5

# The amount of time (in seconds) the muzzle flash meshes are visible.
const FLASH_TIME = 0.1
# A variable for tracking how long the muzzle flash meshes have been visible.
var flash_timer = 0

# The amount of time (in seconds) needed to fire a bullet.
const FIRE_TIME = 0.8
# A variable for tracking how much time has passed since the turret last fired.
var fire_timer = 0

# A variable to hold the Head node.
var node_turrent_head = null
# A variable to hold the Raycast node attached to the turret’s head.
var node_raycast = null
# A variable to hold the first muzzle flash MeshInstance.
var node_flash_one = null
# A variable to hold the second muzzle flash MeshInstance.
var node_flash_two = null

# The amount of ammo currently in the turret.
var ammo_in_turrent = 20
# The amount of ammo in a full turret.
const AMMO_IN_FULL_TURRENT = 20
# The amount of time it takes the turret to reload.
const AMMO_RELOAD_TIME = 4
# A variable for tracking how long the turret has been reloading.
var ammo_reload_timer = 0

# The turret’s current target.
var current_target = null

# A variable for tracking whether the turret is able to fire at the target.
var is_active = false

# The amount of height we’re adding to the target so we’re not shooting at its feet.
const PLAYER_HEIGHT = 3

# A variable to hold the smoke particles node.
var smoke_particles

# The amount of health the turret currently has.
var turrent_health = 60
# The amount of health a fully healed turret has.
const MAX_TURRENT_HEALTH = 60

# The amount of time (in seconds) it takes for a destroyed turret to repair itself.
const DESTROYED_TIME = 20
# A variable for tracking the amount of time a turret has been destroyed.
var destroyed_timer = 0

# The bullet scene the turret fires (same scene as the player’s pistol)
var bullet_scene = preload("res://Bullet_Scene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$Vision_Area.connect("body_entered", self, "body_entered_vision")
	$Vision_Area.connect("body_exited", self, "body_exited_vision")
	
	node_turrent_head = $Head
	node_raycast = $Head/Ray_Cast
	node_flash_one = $Head/Flash
	node_flash_two = $Head/Flash_2
	
	node_raycast.add_exception(self)
	node_raycast.add_exception($Base/Static_Body)
	node_raycast.add_exception($Head/Static_Body)
	node_raycast.add_exception($Vision_Area)
	
	node_flash_one.visible = false
	node_flash_two.visible = false
	
	smoke_particles = $Smoke
	# set emitting to false to ensure the particles are not 
	# emitting until the turret is broken.
	smoke_particles.emitting = false
	
	turrent_health = MAX_TURRENT_HEALTH

func _physics_process(delta):
	if is_active == true:
		if flash_timer >0:
			flash_timer -= delta
			
			if flash_timer <= 0:
				node_flash_one.visible = false
				node_flash_two.visible = false
		
		if current_target != null:
			node_turrent_head.look_at(current_target.global_transform.origin + Vector3(0, PLAYER_HEIGHT, 0), Vector3(0,1,0))
			
			if turrent_health > 0:
				if ammo_in_turrent >0:
					if fire_timer > 0:
						fire_timer -= delta
					else:
						fire_bullet()
				else:
					if ammo_reload_timer > 0:
						ammo_reload_timer -= delta
					else:
						ammo_in_turrent = AMMO_IN_FULL_TURRENT
	
	if turrent_health <= 0:
		if destroyed_timer > 0:
			destroyed_timer -= delta
		else:
			turrent_health = MAX_TURRENT_HEALTH
			smoke_particles.emitting = false

func fire_bullet():
	if use_raycast == true:
		node_raycast.look_at(current_target.global_transform.origin + Vector3(0, PLAYER_HEIGHT, 0), Vector3(0,1,0))
		
		node_raycast.force_raycast_update()
		
		if node_raycast.is_colliding():
			var body = node_raycast.get_collider()
			if body.has_method("bullet_hit"):
				body.bullet_hit(TURRENT_DAMAGE_RAYCAST, node_raycast.get_collision_point())
		
		ammo_in_turrent -= 1
	
	else:
		var clone = bullet_scene.instance()
		var scene_root = get_tree().root.get_child(0)
		scene_root.add_child(clone)
		
		clone.global_transform = $Head/Barrel_End.global_transform
		clone.scale = Vector3(8,8,8)
		clone.BULLET_DAMAGE = TURRENT_DAMAGE_BULLET
		clone.BULLET_SPEED = 60
		
		ammo_in_turrent -= 1
	
	node_flash_one.visible = true
	node_flash_two.visible = true
	
	flash_timer = FLASH_TIME
	fire_timer = FIRE_TIME
	
	if ammo_in_turrent <= 0:
		ammo_reload_timer = AMMO_RELOAD_TIME

func body_entered_vision(body):
	if current_target == null:
		if body is KinematicBody:
			current_target = body
			is_active = true

func body_exited_vision(body):
	if current_target != null:
		if body == current_target:
			current_target = null
			is_active = false
			
			flash_timer = 0
			fire_timer = 0
			node_flash_one.visible = false
			node_flash_two.visible = false

func bullet_hit(damage, bullet_hit_pos):
	turrent_health -= damage
	
	if turrent_health <= 0:
		smoke_particles.emitting = true
		destroyed_timer = DESTROYED_TIME