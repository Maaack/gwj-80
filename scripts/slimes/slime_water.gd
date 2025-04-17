class_name SlimeWater
extends Slime

## A slime that pushes nearby slimes in the direction that it is moving, like
## the current of a river.  Updates the push direction periodically, based on the timer.


@export var push_magnitude: float = 0.1
@export var update_push_cooldown: float = 3.0

var last_push_velocity := Vector3.ZERO

@onready var update_push_timer: Timer = %UpdatePushTimer


func _ready() -> void:
	super()
	update_push_timer.wait_time = update_push_cooldown
	update_push_timer.start()


func apply_effects_to_nearby_slimes() -> void:
	var push_velocity: Vector3 = velocity.normalized() * push_magnitude

	for slime: Slime in nearby_slimes:
		slime.push_velocities.erase(last_push_velocity)
		slime.push_velocities.append(push_velocity)

	last_push_velocity = push_velocity


## Stop tracking slimes that leave the area and remove the push effect from them.
func _on_flocking_zone_body_exited(body: Node3D) -> void:
	if body is not Slime:
		return

	var slime: Slime = body
	nearby_slimes.erase(body)
	slime.push_velocities.erase(last_push_velocity)


func _on_update_push_timer_timeout() -> void:
	apply_effects_to_nearby_slimes()
