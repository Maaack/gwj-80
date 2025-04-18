class_name SlimeMoss
extends Slime

## A slime that grows bigger, grows nearby slimes, and has a chance to create a
## slime of a type that is nearby.


@export_category("Growth settings")
@export var min_grow_time: float = 30.0
@export var max_grow_time: float = 60.0
@export var growth_amount: int = 1
@export var mass_grow_threshold: int = 4
@export var create_new_slime_chance: float = 0.25

@onready var grow_timer: Timer = %GrowTimer


func _ready() -> void:
	super()

	grow_timer.start(randf_range(min_grow_time, max_grow_time))


## If this slime's mass is less than the threshold, grows itself.
## If greater than the threshold, it has a random chance to either grow a
## nearby slime, or create a new slime of a type that is nearby.
func _on_grow_timer_timeout() -> void:
	if mass < mass_grow_threshold:
		grow(mass + growth_amount)
	elif not nearby_slimes.is_empty():
		var chosen_slime: Slime = nearby_slimes.pick_random()

		if randf() < create_new_slime_chance:
			create_new_slime(chosen_slime)
		else:
			chosen_slime.grow(chosen_slime.mass + growth_amount)

	grow_timer.start(randf_range(min_grow_time, max_grow_time))


func grow_slime(slime: Slime) -> void:
	slime.set_slime_scale(slime.get_slime_scale() + growth_amount)
