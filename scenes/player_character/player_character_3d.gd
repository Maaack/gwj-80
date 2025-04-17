## Modified version of Third Person Controller
## by emirthab - MIT License

class_name PlayerCharacter
extends CharacterBody3D

@onready var animation_tree : AnimationTree = $AnimationTree
@onready var playback : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

# Allows to pick your chracter's mesh from the inspector
@export_node_path("Node3D") var PlayerCharacterMesh: NodePath
@onready var player_mesh : Node3D = get_node(PlayerCharacterMesh)
@onready var whistling_player: AudioStreamPlayer3D = %WhistlingStreamPlayer3D
@onready var note_1_particles: GPUParticles3D = $Note1Particles3D
@onready var note_2_particles: GPUParticles3D = $Note2Particles3D

# Gamplay mechanics and Inspector tweakables
@export var gravity : float = 9.8
@export var jump_force : float = 9
@export var walk_speed : float = 1.3
@export var run_speed : float = 5.5
@export var dash_power : float = 12 # Controls roll and big attack speed boosts
@export var character_model : Node3D

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

func _ready() -> void:
	direction = Vector3.BACK.rotated(Vector3.UP, $CustomCamera/h.global_transform.basis.get_euler().y)

func _input(event) -> void:
	if event.is_action_pressed("attract_slimes"):
		is_whistling = true
		whistling_player.play()
		note_1_particles.emitting = true
		note_2_particles.emitting = true
	elif event.is_action_released("attract_slimes"):
		is_whistling = false
		whistling_player.stop()
		note_1_particles.emitting = false
		note_2_particles.emitting = false

func _physics_process(delta : float) -> void:
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
	player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(direction.x, direction.z) - rotation.y, delta * angular_acceleration)
	
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
