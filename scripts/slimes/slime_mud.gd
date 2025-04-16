class_name SlimeMud
extends Slime

## A slime that slows down nearby slimes.


# All slimes have a speed modifier, this one has a value used to set
# other slimes' speed modifiers.
@export var speed_mod_for_others: float = 0.5


## Keep track of the slimes that within the area.
func _on_flocking_zone_body_entered(body: Node3D) -> void:
	if body is not Slime or body == self:
		return

	var slime: Slime = body
	nearby_slimes.append(slime)
	slime.speed_modifier = speed_mod_for_others


## Stop tracking slimes that leave the area and reset the grow time if there
## are no water slimes nearby.
func _on_flocking_zone_body_exited(body: Node3D) -> void:
	if body is not Slime:
		return

	var slime: Slime = body
	nearby_slimes.erase(slime)

	# Remove the slow effect, if there are no other mud slimes applying it.
	if not slime.nearby_slimes.any(func(nearby_slime: Slime) -> bool: return (nearby_slime is SlimeMud and nearby_slime != self)):
		slime.speed_modifier = 1.0
