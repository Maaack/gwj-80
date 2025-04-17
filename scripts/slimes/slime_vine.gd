class_name SlimeVine
extends Slime

## A slime that will grow in size if it is near water slimes for a long enough
## time.  Time resets if no water slimes are nearby.


@export var grow_requirement_time: float = 30.0

var num_water_nearby: int = 0
var current_growth_time: float = 0.0
var grow_mass_increase: int = 2


func _process(delta: float) -> void:
	# Increment the timer for each water slime nearby
	current_growth_time += delta * num_water_nearby
	if current_growth_time >= grow_requirement_time:
		current_growth_time = 0.0
		grow(mass + grow_mass_increase)


## Keep track of the slimes that within the area.
func _on_flocking_zone_body_entered(body: Node3D) -> void:
	if body is not Slime or body == self:
		return

	var slime: Slime = body
	nearby_slimes.append(slime)

	if slime is SlimeWater:
		num_water_nearby += 1


## Stop tracking slimes that leave the area and reset the grow time if there
## are no water slimes nearby.
func _on_flocking_zone_body_exited(body: Node3D) -> void:
	if body is not Slime:
		return

	var slime: Slime = body
	nearby_slimes.erase(slime)

	if slime is SlimeWater:
		num_water_nearby -= 1
		if num_water_nearby <= 0:
			current_growth_time = 0.0
