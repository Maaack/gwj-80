class_name Slime
extends CharacterBody3D

@export_category("Boid Rule Weights")
@export var cohesion_weight: float = 0.0005
@export var separation_weight: float = 0.01
@export var alignment_weight: float = 0.000525
@export var target_location_weight: float = 0.005
@export var target_location_repel_weight: float = 0.1

@export_category("Boid Settings")
@export var separation_distance: float = 3.5
@export var separation_max_magnitude: float = 0.1
@export var target_location_radius: float = 3.5
@export var target_location_max_magnitude: float = 0.2

@export_category("Movement Settings")
@export var min_speed: float = 2.0
@export var max_speed: float = 3.0
@export var turn_speed: float = 1.0
@export var external_velocity_weight: float = 1.0
@export var external_velocity_deceleration: float = 6.0
@export var ambient_direction_update_cooldown: float = 5.0

var nearby_slimes: Array[Slime] = []
var attract_locations: Array[Vector3] = []
var repel_locations: Array[Vector3] = []
var push_velocities: Array[Vector3] = []
var is_scattering: bool = false
var is_idle: bool = false

var _player: PlayerCharacter

var speed_modifier: float = 1.0
var external_velocity: Vector3 = Vector3.ZERO
var default_collision_shape_radius: float
var scale_tween: Tween

@onready var pivot: Node3D = %Pivot
@onready var update_ambient_direction_timer: Timer = %UpdateAmbientDirectionTimer
@onready var collision_shape: CollisionShape3D = %CollisionShape
@onready var flocking_zone_collision_shape: CollisionShape3D = %FlockingZoneCollisionShape

var slime_data : SlimeData = SlimeData.new()

## Sets a random initial velocity
func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")
	update_ambient_direction_timer.wait_time = ambient_direction_update_cooldown
	set_random_movement_direction()
	default_collision_shape_radius = get_collision_shape_radius()


func _physics_process(delta: float) -> void:
	var cohesion: Vector3 = calc_cohesion()
	var separation: Vector3 = calc_separation()
	var alignment: Vector3 = calc_alignment()

	cohesion.y = 0.0
	separation.y = 0.0
	alignment.y = 0.0

	velocity += cohesion + separation + alignment

	for attract_location: Vector3 in attract_locations:
		var attraction: Vector3 = calc_attract_location(attract_location)
		attraction.y = 0.0
		velocity += attraction

	for repel_location: Vector3 in repel_locations:
		var repulsion: Vector3 = calc_repel_location(repel_location)
		repulsion.y = 0.0
		velocity += repulsion

	if velocity.length() > (max_speed * speed_modifier):
		velocity = velocity.normalized() * randf_range(min_speed * speed_modifier, max_speed * speed_modifier)

	for push_velocity: Vector3 in push_velocities:
		velocity += push_velocity

	# NOTE: This would be more efficient if checked when these conditions change, rather than every physics update.
	if not is_idle and nearby_slimes.is_empty() and attract_locations.is_empty() and repel_locations.is_empty():
		if update_ambient_direction_timer.is_stopped():
			update_ambient_direction_timer.start()
	elif not update_ambient_direction_timer.is_stopped():
		update_ambient_direction_timer.stop()

	# Rotate the model to face the movement direction, limited by the turn speed.
	pivot.rotation.y = lerpf(pivot.rotation.y, atan2(-velocity.x, -velocity.z), turn_speed * delta)

	velocity += external_velocity * external_velocity_weight
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


#region Boid Rules


## Boids rule #1
## Slimes will try to move towards other slimes.
func calc_cohesion() -> Vector3:
	if nearby_slimes.is_empty():
		return Vector3.ZERO

	var center := Vector3.ZERO
	for slime: Slime in nearby_slimes:
		center += slime.global_position
	center /= nearby_slimes.size()

	var cohesion: Vector3 = (center - global_position) * cohesion_weight
	if is_scattering:
		cohesion *= -1

	return cohesion


## Boids rule #2
## Slimes will try to avoid running into other slimes.
func calc_separation() -> Vector3:
	if nearby_slimes.is_empty():
		return Vector3.ZERO

	var separation := Vector3.ZERO
	for slime: Slime in nearby_slimes:
		if global_position.distance_to(slime.global_position) <= separation_distance:
			var delta_distance: Vector3 = slime.global_position - global_position
			separation += (delta_distance - delta_distance.normalized() * separation_distance)

	# Cap the separation vector's magnitude to prevent sudden 'spikes' that cause
	# erratic, flickering movements.
	return (separation * separation_weight).limit_length(separation_max_magnitude)


## Boids rule #3
## Slimes will try to match the direction of nearby slimes.
func calc_alignment() -> Vector3:
	if nearby_slimes.is_empty():
		return Vector3.ZERO

	var avg_velocity := Vector3.ZERO
	for slime: Slime in nearby_slimes:
		avg_velocity += slime.velocity
	avg_velocity /= nearby_slimes.size()

	return (avg_velocity - velocity) * alignment_weight


## Slimes will try to move towards a particular location.
func calc_attract_location(attract_location: Vector3) -> Vector3:
	var distance_to_target_center: Vector3 = (attract_location - global_position)
	# No forces applied within a zone around the target.
	if distance_to_target_center.length() < target_location_radius:
		return Vector3.ZERO # -velocity.limit_length(0.001)

	# Apply force proportional to distance to the edge of the target zone.
	var distance_to_target_zone: Vector3 = \
		distance_to_target_center.normalized() * \
		(distance_to_target_center.length() - target_location_radius)

	return (distance_to_target_zone * target_location_weight).limit_length(target_location_max_magnitude)


## Slimes will try to move away from a particular location.
func calc_repel_location(repel_location: Vector3) -> Vector3:
	var distance_to_target_center: Vector3 = (repel_location - global_position)

	# Full force applied within the target_location_radius
	if distance_to_target_center.length() < target_location_radius:
		return -distance_to_target_center.normalized() * target_location_max_magnitude

	# Partial force applied based on how far the slime is from the repulsion location.
	var distance_to_target_zone: float = distance_to_target_center.length() - target_location_radius
	var force_falloff: float = distance_to_target_zone * target_location_repel_weight

	# No forces applied outside of the falloff zone.
	if force_falloff > target_location_max_magnitude:
		return Vector3.ZERO

	return (target_location_max_magnitude - force_falloff) * -distance_to_target_center.normalized()


#endregion


#region Nearby slime tracking


## Keep track of the slimes that within the area.
func _on_flocking_zone_body_entered(body: Node3D) -> void:
	if body is not Slime or body == self:
		return

	nearby_slimes.append(body)


## Stop tracking slimes that leave the area.
func _on_flocking_zone_body_exited(body: Node3D) -> void:
	if body is not Slime:
		return

	nearby_slimes.erase(body)


#endregion


func add_external_velocity(ext_velocity: Vector3) -> void:
	external_velocity += ext_velocity


func set_random_movement_direction() -> void:
	velocity = Vector3(randf(), 0.0, randf())
	velocity = velocity.normalized() * max_speed * speed_modifier


func _on_update_ambient_direction_timer_timeout() -> void:
	set_random_movement_direction()


func get_flocking_zone_radius() -> float:
	var shape: SphereShape3D = flocking_zone_collision_shape.shape
	return shape.radius


func set_flocking_zone_radius(new_radius: float) -> void:
	var shape: SphereShape3D = flocking_zone_collision_shape.shape
	shape.radius = new_radius


func get_collision_shape_radius() -> float:
	var shape: SphereShape3D = collision_shape.shape
	return shape.radius


func set_collision_shape_radius(new_radius: float) -> void:
	var shape: SphereShape3D = collision_shape.shape
	shape.radius = new_radius


func tween_scale(new_scale: Vector3, duration: float) -> void:
	if scale_tween and scale_tween.is_running():
		scale_tween.kill()
	scale_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	scale_tween.tween_property(pivot, "scale", new_scale, duration)


func set_slime_scale(new_scale: float) -> void:
	if pivot.scale.x == new_scale:
		return

	tween_scale(Vector3(new_scale, new_scale, new_scale), 0.75)

	var current_radius: float = get_collision_shape_radius()
	var new_radius: float = default_collision_shape_radius * new_scale
	var radius_increase: float = new_radius - current_radius
	set_collision_shape_radius(new_radius)
	collision_shape.position.y += radius_increase
	set_flocking_zone_radius(get_flocking_zone_radius() + radius_increase)
