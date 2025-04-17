class_name SlimeFire
extends Slime

## A slime that moves faster, grows other fire slimes that are close to it,
## and shrinks over time.

@export_category("Shrink Settings")
@export var shrink_amount: float = 0.15
@export var shrink_cooldown: float = 60.0

@export_category("Fire Spread Settings")
## How close another fire slime must be to be grown by this one
@export var fire_spread_distance: float = 1.5
## How often this slime can grow nearby fire slimes
@export var fire_spread_cooldown: float = 45.0
## The maximum amount this slime can grow another one at once.  This affects the
## other slime's scale.
@export var max_spread_amount: float = 0.3

var is_fire_spread_available: bool = true

@onready var shrink_timer: Timer = %ShrinkTimer
@onready var spread_timer: Timer = %SpreadTimer


func _ready() -> void:
	super()

	spread_timer.wait_time = fire_spread_cooldown
	shrink_timer.wait_time = shrink_cooldown
	shrink_timer.start()


func _physics_process(delta: float) -> void:
	super(delta)

	if not is_fire_spread_available:
		return

	# Grows all fire slimes within range, then puts the spread ability on cooldown.
	for slime: Slime in nearby_slimes:
		# If the nearby slime is not a fire slime, or is not close enough, don't try to grow it.
		if slime is not SlimeFire or (slime.global_position.distance_to(global_position) \
				- get_collision_shape_radius() - slime.get_collision_shape_radius()) > fire_spread_distance:
			continue
		is_fire_spread_available = false
		if spread_timer.is_stopped():
			spread_timer.start()
		slime.set_slime_scale(slime.get_slime_scale() + minf(get_slime_scale(), max_spread_amount))


## Has a chance to shrink whenever this timer finishes.
func _on_shrink_timer_timeout() -> void:
	if randi_range(0, 1) == 0:
		set_slime_scale(get_slime_scale() - shrink_amount)


func _on_spread_timer_timeout() -> void:
	is_fire_spread_available = true
