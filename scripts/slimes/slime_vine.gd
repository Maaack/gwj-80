class_name SlimeVine
extends Slime

## A slime that will grow in size if it is near water slimes for a long enough
## time.  Time resets if no water slimes are nearby.


@export var default_grow_requirement_time: float = 30.0

var num_water_nearby: int = 0
var grow_requirement_time: float
var current_growth_time: float = 0.0

var current_growth_stage: int = 0
var growth_scales: Array[float] = [ 1.0, 2.0, 3.0, 4.0 ]


func _ready() -> void:
	super()
	# Store the default value, so the property can be scaled from the default,
	# as opposed to the current value.
	grow_requirement_time = default_grow_requirement_time


func _process(delta: float) -> void:
	# Increment the timer for each water slime nearby
	current_growth_time += delta * num_water_nearby
	if current_growth_time >= grow_requirement_time:
		grow_vine()


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


## Increase the model scale, the collision shape radius, and the flocking shape radius
func grow_vine() -> void:
	# Check if there is another size to increase to
	if current_growth_stage < growth_scales.size() - 1:
		current_growth_time = 0.0
		current_growth_stage += 1
		var new_scale: float = growth_scales[current_growth_stage]
		set_slime_scale(new_scale)
		grow_requirement_time = default_grow_requirement_time * new_scale
