extends Node3D

var camrot_h = 0
var camrot_v = 0
@export var cam_v_max : float = 25 
@export var cam_v_min : float = -15
@export var joystick_sensitivity : float = 20
@export var min_spring_length : float = 4.0
@export var max_spring_length : float = 8.0
var h_sensitivity = .01
var v_sensitivity = .01
var h_acceleration = 10
var v_acceleration = 10
var joyview = Vector2()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event is InputEventMouseMotion:
	
		camrot_h += -event.relative.x * h_sensitivity
		camrot_v += event.relative.y * v_sensitivity
		
func _joystick_input():
	if (Input.is_action_pressed("look_up") ||  Input.is_action_pressed("look_down") ||  Input.is_action_pressed("look_left") ||  Input.is_action_pressed("look_right")):
		
		joyview.x = Input.get_action_strength("look_left") - Input.get_action_strength("look_right")
		joyview.y = Input.get_action_strength("look_up") - Input.get_action_strength("look_down")
		camrot_h += joyview.x * joystick_sensitivity * h_sensitivity
		camrot_v += joyview.y * joystick_sensitivity * v_sensitivity 
		
func _physics_process(delta):
	# JoyPad Controls
	_joystick_input()
		
	camrot_v = clamp(camrot_v, deg_to_rad(cam_v_min), deg_to_rad(cam_v_max))
	var ratio := smoothstep(deg_to_rad(cam_v_min), deg_to_rad(cam_v_max), camrot_v)

	$h.rotation.y = lerpf($h.rotation.y, camrot_h, delta * h_acceleration)
	$h/v.rotation.x = lerpf($h/v.rotation.x, camrot_v, delta * v_acceleration)
	$h/v/Arm.spring_length = -(min_spring_length + ((max_spring_length - min_spring_length) * ratio))
	
