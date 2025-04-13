class_name Slime
extends CharacterBody3D

@export_category("Boid Rule Weights")
@export var cohesion_weight: float = 0.0005
@export var separation_weight: float = 0.01
@export var alignment_weight: float = 0.000525

@export_category("Boid Separation Settings")
@export var min_separation: float = 3.5
@export var max_separation_magnitude: float = 0.1

@export_category("Movement Settings")
@export var min_speed: float = 2.0
@export var max_speed: float = 3.0
@export var return_in_bounds_velocity: float = 10.0

var nearby_slimes: Array[Slime] = []

@onready var pivot: Node3D = %Pivot
@onready var debug_label: Label3D = %DebugLabel


## Sets a random initial velocity
func _ready() -> void:
	velocity = Vector3(randf(), 0.0, randf())
	velocity = velocity.normalized() * max_speed


# TODO: Add gravity
func _physics_process(delta: float) -> void:
	#debug_label.text = "V: %.3v (%.3f)\nC: %.3v (%.3f)\nS: %.3v (%.3f)\nA: %.3v (%.3f)" % [
		#velocity,
		#velocity.length(),
		#calc_cohesion(),
		#calc_cohesion().length(),
		#calc_separation(),
		#calc_separation().length(),
		#calc_alignment(),
		#calc_alignment().length()
	#]

	velocity += calc_cohesion() + calc_separation() + calc_alignment()
	velocity.y = 0.0
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * randf_range(min_speed, max_speed)

	bound_position(delta)
	pivot.look_at(global_position + velocity)
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

	return (center - global_position) * cohesion_weight


## Boids rule #2
## Slimes will try to avoid running into other slimes.
func calc_separation() -> Vector3:
	if nearby_slimes.is_empty():
		return Vector3.ZERO

	var separation := Vector3.ZERO
	for slime: Slime in nearby_slimes:
		if global_position.distance_to(slime.global_position) <= min_separation:
			var delta_distance: Vector3 = slime.global_position - global_position
			separation += (delta_distance - delta_distance.normalized() * min_separation)

	# Cap the separation vector's magnitude to prevent sudden 'spikes' that cause
	# erratic, flickering movements.
	return (separation * separation_weight).limit_length(max_separation_magnitude)


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


#endregion


## Used to create a bounding box that slimes will stay in.  This is useful for testing,
## so the slimes will stay in the camera range and will have chances to change direction.
func bound_position(delta: float) -> void:
	var bounds: float = 25.0
	if global_position.x < -bounds:
		velocity.x = return_in_bounds_velocity
	elif global_position.x > bounds:
		velocity.x = -return_in_bounds_velocity

	if global_position.z < -bounds:
		velocity.z = return_in_bounds_velocity
	elif global_position.z > bounds:
		velocity.z = -return_in_bounds_velocity


## Keep track of the slimes that within the area.
func _on_flocking_zone_body_entered(body: Node3D) -> void:
	if body is not Slime or body == self:
		return

	nearby_slimes.append(body)

## Stop tracking slimes that leave the area.
func _on_flocking_zone_body_exited(body: Node3D) -> void:
	if body.owner is not Slime:
		return

	nearby_slimes.erase(body.owner)
