class_name SlimeAsh
extends Slime

## A slime that will periodically cause nearby slimes to scatter.


@export var scatter_duration: float = 5.0
@export var scatter_effect_cooldown: float = 30.0

@onready var scatter_effect_timer: Timer = %ScatterEffectTimer


func _ready() -> void:
	super()
	scatter_effect_timer.wait_time = scatter_effect_cooldown
	scatter_effect_timer.start()


func apply_effects_to_nearby_slimes() -> void:
	# Duplicate the array, because nearby slimes may change before the timeout
	# signal is emitted.
	var affected_slimes: Array[Slime] = nearby_slimes.duplicate()

	for slime: Slime in affected_slimes:
		slime.is_scattering = true

	get_tree().create_timer(scatter_duration, false).timeout.connect(
		remove_effects_from_slimes.bind(affected_slimes)
	)


func remove_effects_from_slimes(slimes: Array[Slime]) -> void:
	for slime: Slime in slimes:
		slime.is_scattering = false


func _on_scatter_effect_timer_timeout() -> void:
	apply_effects_to_nearby_slimes()
