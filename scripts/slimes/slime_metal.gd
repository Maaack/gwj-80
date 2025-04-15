class_name SlimeMetal
extends Slime

## A slime that does not move on its own, but can be moved by external forces.


## Override the _ready function, because the base class gives slimes an initial velocity.
func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")


## Override the physics_process, to make the external velocity the only factor that moves this slime.
func _physics_process(delta: float) -> void:
	# Rotate the model to face the movement direction, limited by the turn speed.
	pivot.rotation.y = lerpf(pivot.rotation.y, atan2(-velocity.x, -velocity.z), turn_speed * delta)

	velocity += external_velocity
	# Decelerate gradually, simulating linear drag.
	if is_on_floor():
		external_velocity = external_velocity.move_toward(Vector3.ZERO, external_velocity_deceleration * 2 * delta)
	else:
		external_velocity = external_velocity.move_toward(Vector3.ZERO, external_velocity_deceleration * delta)

	# If a slime collides with something, it will be unable to continue moving in that direction,
	# so the real velocity in that direction is 0.  Reducing external velocity when this happens
	# prevents the slime from being pinned to the object.  Essentially, it increases the linear drag.
	var real_velocity: Vector3 = get_real_velocity()
	if real_velocity.x == 0.0:
		external_velocity.x *= 0.9
	if real_velocity.y == 0.0:
		external_velocity.y *= 0.9
	if real_velocity.z == 0.0:
		external_velocity.z *= 0.9

	# Y velocity is zeroed after the boids rules are applied, so the boids do not try to fly.
	# So this is added after that, and after the velocity gets normalized, so the gravity
	# will be consistent.
	if not is_on_floor():
		velocity += get_gravity()

	move_and_slide()
