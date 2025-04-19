## Modified version of Third Person Controller
## by emirthab - MIT License

class_name PlayerCharacter
extends CharacterBody3D

signal slime_type_observed(slime_type: Constants.SlimeType, amount: float)
signal interaction_entered
signal interaction_exited

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var playback : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

# Allows to pick your chracter's mesh from the inspector
@export_node_path("Node3D") var PlayerCharacterMesh: NodePath
@onready var player_mesh : Node3D = get_node(PlayerCharacterMesh)
@onready var whistling_player: AudioStreamPlayer3D = %WhistlingStreamPlayer3D
@onready var note_1_particles: GPUParticles3D = $Note1Particles3D
@onready var note_2_particles: GPUParticles3D = $Note2Particles3D
@onready var fade_rect: ColorRect = %FadeRect
@onready var interaction_zone: Area3D = %InteractionZone
@onready var camera: Node3D = $CustomCamera

# Gamplay mechanics and Inspector tweakables
@export var gravity : float = 9.8
@export var jump_force : float = 9
@export var walk_speed : float = 1.3
@export var run_speed : float = 5.5
@export var dash_power : float = 12 # Controls roll and big attack speed boosts
@export var character_model : Node3D
@export var fade_transition_duration: float = 1.0

@export_category("Bounding Box")
@export var min_bounds := Vector3(-80.0, 0.0, -80.0)
@export var max_bounds := Vector3(80.0, 0.0, 80.0)

@export_category("Nudge Settings")
@export var nudge_strength := Vector3(4.0, 4.0, 4.0)

# Animation node names
var roll_node_name : String= "Roll"
var idle_node_name : String= "Idle"
var walk_node_name : String= "Walk"
var run_node_name : String= "Run"
var jump_node_name : String= "Jump"
var dance_node_name : String= "Dance"
var attack2_node_name : String= "Attack2"
var bigattack_node_name : String= "BigAttack"
var rollattack_node_name : String= "RollAttack"

# Condition States
var is_walking : bool = false
var is_running : bool = false
var should_stop_dancing : bool = false

# Physics values
var direction : Vector3
var horizontal_velocity : Vector3
var movemen : Vector3
var vertical_velocity : Vector3
var movement_speed : float
var angular_acceleration : float
var acceleration : float
var selected_outfit : Node3D
var stop_movement_inputs : bool = false
var is_whistling : bool = false
var is_journaling : bool = false :
	set(value):
		is_journaling = value
		if is_inside_tree():
			camera.disabled = is_journaling
var initial_position: Vector3

# Tweens
var fade_tween: Tween
var observed_slimes : Array[Slime]
var interactable : Node3D :
	set(value):
		interactable = value
		if interactable:
			interaction_entered.emit()
		else:
			interaction_exited.emit()

# Nearby slimes
var interactable_slimes: Array[Slime] = []
var last_highlighted_slime: Slime


func _ready() -> void:
	direction = Vector3.BACK.rotated(Vector3.UP, $CustomCamera/h.global_transform.basis.get_euler().y)
	initial_position = global_position

func _start_whistling() -> void:
	is_whistling = true
	whistling_player.volume_db = 0
	note_1_particles.emitting = true
	await get_tree().create_timer(0.25).timeout
	if is_whistling:
		note_2_particles.emitting = true

func _stop_whistling() -> void:
	is_whistling = false
	var tween = create_tween()
	tween.tween_property(whistling_player, "volume_db", -80, 0.2)
	note_1_particles.emitting = false
	note_2_particles.emitting = false

func _input(event) -> void:
	if is_journaling : return
	if event.is_action_pressed("attract_slimes"):
		_start_whistling()
	elif event.is_action_released("attract_slimes"):
		_stop_whistling()
	if event.is_action_pressed("interact"):
		if interactable:
			if interactable.has_method(&"interact"):
				interactable.call(&"interact")
		else:
			_nudge_nearest_slime()


func _physics_process(delta : float) -> void:
	_highlight_closest_slime()

	if stop_movement_inputs:
		return
	var on_floor := is_on_floor() # State control for is jumping/falling/landing
	var h_rot : float = $CustomCamera/h.global_transform.basis.get_euler().y

	movement_speed = 0
	angular_acceleration = 10
	acceleration = 15

	# Gravity mechanics and prevent slope-sliding
	if not is_on_floor():
		vertical_velocity += Vector3.DOWN * gravity * 2 * delta
	else:
		#vertical_velocity = -get_floor_normal() * gravity / 3
		vertical_velocity = Vector3.DOWN * gravity / 10

	if is_journaling: return
#	Jump input and Mechanics
	if Input.is_action_just_pressed("jump") and is_on_floor():
		vertical_velocity = Vector3.UP * jump_force

	# Movement input, state and mechanics. *Note: movement stops if attacking
	if (Input.is_action_pressed("move_forward") ||  Input.is_action_pressed("move_backward") ||  Input.is_action_pressed("move_left") ||  Input.is_action_pressed("move_right")):
		direction = Vector3(Input.get_action_strength("move_left") - Input.get_action_strength("move_right"),
					0,
					Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward"))
		direction = direction.rotated(Vector3.UP, h_rot).normalized()
		is_walking = true

	# Walk input, dash state and movement speed
		if not Input.is_action_pressed("walk") and (is_walking == true ) and (is_whistling == false):
			movement_speed = run_speed
			is_running = true
		else: # Walk State and speed
			movement_speed = walk_speed
			is_running = false
	else:
		is_walking = false
		is_running = false

	#if Input.is_action_pressed("aim"):  # Aim/Strafe input and  mechanics
		#player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, $Camroot/h.rotation.y, delta * angular_acceleration)

	#else: # Normal turn movement mechanics
	var new_rotation: float = lerp_angle(player_mesh.rotation.y, atan2(direction.x, direction.z) - rotation.y, delta * angular_acceleration)
	player_mesh.rotation.y = new_rotation
	interaction_zone.rotation.y = new_rotation


	horizontal_velocity = horizontal_velocity.lerp(direction.normalized() * movement_speed, acceleration * delta)

	# The Physics Sauce. Movement, gravity and velocity in a perfect dance.
	velocity.z = horizontal_velocity.z + vertical_velocity.z
	velocity.x = horizontal_velocity.x + vertical_velocity.x
	velocity.y = vertical_velocity.y

	move_and_slide()

	# ========= State machine controls =========
	# The booleans of the on_floor, is_walking etc, trigger the
	# advanced conditions of the AnimationTree, controlling animation paths

	# on_floor manages jumps and falls
	animation_tree["parameters/conditions/IsOnFloor"] = on_floor
	animation_tree["parameters/conditions/IsInAir"] = !on_floor
	# Moving and running respectively
	animation_tree["parameters/conditions/IsWalking"] = is_walking
	animation_tree["parameters/conditions/IsNotWalking"] = !is_walking
	animation_tree["parameters/conditions/IsRunning"] = is_running
	animation_tree["parameters/conditions/IsNotRunning"] = !is_running
	animation_tree["parameters/conditions/IsWhistling"] = is_whistling
	animation_tree["parameters/conditions/IsNotWhistling"] = !is_whistling

func _on_area_3d_body_entered(body):
	if body is Slime:
		body._pc = self
		observed_slimes.append(body)

func _on_area_3d_body_exited(body):
	if body is Slime:
		body._pc = null
		observed_slimes.erase(body)

## If the player is outside of the bounds, reset their position to their initial spawn location.
func _on_bounds_check_timer_timeout() -> void:
	if global_position.x < min_bounds.x or global_position.x > max_bounds.x \
			or global_position.z < min_bounds.z or global_position.z > max_bounds.z:
		_tween_respawn()


func _reset_position() -> void:
	global_position = initial_position


## Fade the screen to black, move the character to their initial spawn location,
## and then unfade the screen.
func _tween_respawn() -> void:
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()

	fade_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	fade_tween.tween_property(fade_rect, "self_modulate:a", 1.0, fade_transition_duration / 2)
	fade_tween.tween_callback(_reset_position)
	fade_tween.set_ease(Tween.EASE_IN)
	fade_tween.tween_property(fade_rect, "self_modulate:a", 0.0, fade_transition_duration / 2)


func _on_interaction_zone_body_entered(body: Node3D) -> void:
	if body is Slime:
		interactable_slimes.append(body)


func _on_interaction_zone_body_exited(body: Node3D) -> void:
	if body is Slime:
		interactable_slimes.erase(body)
		body.is_nudgeable = false
		if body == last_highlighted_slime:
			last_highlighted_slime.is_nudgeable = false
			last_highlighted_slime = null


func _nudge_nearest_slime() -> void:
	if interactable_slimes.is_empty():
		return

	var closest_slime: Slime = _get_closest_slime()

	var direction: Vector3 = global_position.direction_to(closest_slime.global_position)
	closest_slime.add_external_velocity(direction * nudge_strength)


func _is_closer_to_player(slime_a: Slime, slime_b: Slime) -> bool:
	var dist_a: float = global_position.distance_to(slime_a.global_position)
	var dist_b: float = global_position.distance_to(slime_b.global_position)

	return dist_a < dist_b


func _get_closest_slime() -> Slime:
	return interactable_slimes.reduce(
		func(closest_slime: Slime, current_slime: Slime) -> Slime:
		return current_slime if _is_closer_to_player(current_slime, closest_slime) else closest_slime
	)


## Show the nudgeable indicator of the closest slime and store the slime,
## so the indicator can be hidden if it leaves the area or is no longer the closest.
func _highlight_closest_slime() -> void:
	if interactable_slimes.is_empty():
		return

	var closest_slime: Slime = _get_closest_slime()
	if last_highlighted_slime == null:
		last_highlighted_slime = closest_slime
		closest_slime.is_nudgeable = true
	elif closest_slime != last_highlighted_slime:
		last_highlighted_slime.is_nudgeable = false
		last_highlighted_slime = closest_slime
		closest_slime.is_nudgeable = true

func _on_discover_timer_timeout():
	var slime_type_count : Dictionary[Constants.SlimeType, int]
	for observed_slime in observed_slimes:
		var slime_type = observed_slime.slime_type
		if slime_type not in slime_type_count:
			slime_type_count[slime_type] = 0
		slime_type_count[slime_type] += 1
	for slime_type in slime_type_count:
		var disovery_progress : float = slime_type_count[slime_type] * 0.0025
		slime_type_observed.emit(slime_type, disovery_progress)
