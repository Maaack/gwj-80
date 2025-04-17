class_name SlimeYinYang
extends Slime

## A slime that will periodically make nearby slimes form a circle.


@export var radial_position_effect_cooldown: float = 45.0
@export var radial_position_effect_duration: float = 12.0

var affected_slimes: Array[Slime] = []

@onready var nearby_slimes_path: Path3D = %NearbySlimesPath
@onready var path_follow: PathFollow3D = %PathFollow
@onready var radial_pos_effect_timer: Timer = %RadialPosEffectTimer
@onready var radial_pos_duration_timer: Timer = %RadialPosDurationTimer


## Create the ring of points that is used for positioning the slimes.
func _ready() -> void:
	super()

	radial_pos_duration_timer.wait_time = radial_position_effect_duration
	radial_pos_effect_timer.wait_time = radial_position_effect_cooldown
	radial_pos_effect_timer.start()

	var num_points: int = 12
	var radius: float = get_flocking_zone_radius() / 2.0

	nearby_slimes_path.curve = Curve3D.new()
	for i: int in num_points:
		nearby_slimes_path.curve.add_point(Vector3(0.0, 0.0, -radius).rotated(Vector3.UP, (i / float(num_points)) * TAU))
	nearby_slimes_path.curve.add_point(Vector3(0.0, 0.0, -radius))


## Give each nearby slime a position spaced out along the circular path.
func give_radial_positions_to_nearby_slimes() -> void:
	for i: int in nearby_slimes.size():
		path_follow.progress_ratio = i / float(nearby_slimes.size())
		give_position_target_to_slime(nearby_slimes[i], path_follow.global_position)


## Set the slime's position to move towards and tell it to ignore other movement rules.
func give_position_target_to_slime(slime: Slime, new_position: Vector3) -> void:
	if slime.use_weights:
		affected_slimes.append(slime)
		slime.direct_move_location = new_position
		slime.use_weights = false


## Tell all affected slimes to start using their movement rules again.
func remove_effect_from_slimes() -> void:
	for i in affected_slimes.size():
		var slime: Slime = affected_slimes.pop_back()
		slime.use_weights = true


func _on_radial_pos_effect_timer_timeout() -> void:
	give_radial_positions_to_nearby_slimes()
	radial_pos_duration_timer.start()


func _on_radial_pos_duration_timer_timeout() -> void:
	remove_effect_from_slimes()
	radial_pos_effect_timer.start()
