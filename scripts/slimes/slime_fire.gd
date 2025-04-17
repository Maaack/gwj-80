class_name SlimeFire
extends Slime

## A slime that moves faster, grows other fire slimes that are close to it,
## and shrinks over time.

@export_category("Shrink Settings")
@export var shrink_amount: int = 1
@export var shrink_cooldown: float = 60.0

@export_category("Fire Spread Settings")
## How often this slime can grow nearby fire slimes
@export var fire_spread_cooldown: float = 30.0
## The maximum amount this slime can grow another one at once.  This affects the
## other slime's scale.
@export var spread_mass_increase: int = 1

var is_fire_spread_available: bool = true

@onready var shrink_timer: Timer = %ShrinkTimer
@onready var spread_timer: Timer = %SpreadTimer


func _ready() -> void:
	super()

	spread_timer.wait_time = fire_spread_cooldown
	shrink_timer.wait_time = shrink_cooldown
	shrink_timer.start()


## Has a chance to shrink whenever this timer finishes.
func _on_shrink_timer_timeout() -> void:
	if randi_range(0, 1) == 0:
		grow(mass - shrink_amount)


func _on_spread_timer_timeout() -> void:
	is_fire_spread_available = true


func _on_touch_zone_body_entered(body: Node3D) -> void:
	super(body)

	if body is SlimeFire and is_fire_spread_available:
		is_fire_spread_available = false
		spread_timer.start()
		grow(body.mass + spread_mass_increase)
