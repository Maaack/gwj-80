class_name SlimeExplosive
extends Slime

## A slime that launches nearby slimes away after a short delay from its creation.

@onready var _explosion_animation_player : AnimationPlayer = %ExplosionAnimationPlayer
@export var explosion_delay: float = 3.0
@export var explosion_force: float = 15.0

var explosion_radius: float = 10.0

var is_exploding: bool = false

func _ready() -> void:
	super()
	get_tree().create_timer(explosion_delay, false).timeout.connect(apply_effects_to_nearby_slimes)
	explosion_radius = get_flocking_zone_radius()

func is_busy() -> bool:
	return super.is_busy() or is_exploding

func apply_effects_to_nearby_slimes() -> void:
	if is_busy(): return
	is_exploding = true
	for slime: Slime in nearby_slimes:
		slime.add_external_velocity(_calculate_explosion_velocity(slime))
		slime.split()
	# TODO: Apply force to player
	var tween = create_tween()
	tween.tween_property(slime_model, "scale", Vector3.ONE * 0.01, 0.25)
	_explosion_animation_player.play(&"Explosion")
	await get_tree().create_timer(2, false).timeout
	depart(0.1)


func _calculate_explosion_velocity(other_node: Node3D) -> Vector3:
	var distance: float = global_position.distance_to(other_node.global_position)
	# Add to the height to generate more lift
	var direction: Vector3 = (other_node.global_position + Vector3(0, 0.5, 0) - global_position).normalized()
	var falloff: float = 1.0 - pow((distance / explosion_radius), 3)

	return direction * explosion_force * falloff
