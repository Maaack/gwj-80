extends Node3D

@export var disabled : bool = false
@export var min_cam_v_degrees : float = -10 
@export var max_cam_v_degrees : float = 40
@export var min_spring_length : float = 4.0
@export var max_spring_length : float = 8.0
@export var min_fov : float = 60.0
@export var max_fov : float = 90.0
@export var min_forward_slide : float = 0.0
@export var max_forward_slide : float = 0.0
@export_range(0, 1) var starting_v_ratio : float = 0.0 :
	set(value):
		starting_v_ratio = value
		_update_camera_position(1.0, starting_v_ratio)
@export_group("Sensitivities")
@export var joystick_sensitivity : float = 20
@export var h_sensitivity : float = .01
@export var v_sensitivity : float = .01
@export var scroll_sensitivity : float = .01
@export var h_acceleration : float = 10
@export var v_acceleration : float = 10

var camrot_h : float = 0
var camrot_v : float = 0
var joyview : Vector2 = Vector2()
var init_mouse_mode : Input.MouseMode 

func _ready():
	init_mouse_mode = Input.mouse_mode
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _exit_tree():
	Input.set_mouse_mode(init_mouse_mode)

func _input(event):
	if disabled: return
	if event is InputEventMouseMotion:
	
		camrot_h += -event.relative.x * h_sensitivity
		camrot_v += event.relative.y * v_sensitivity

	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_DOWN:
				camrot_v += scroll_sensitivity
			MOUSE_BUTTON_WHEEL_UP:
				camrot_v -= scroll_sensitivity

func _update_camera_position(delta : float, v_ratio : float) -> void:
	var min_cam_v = deg_to_rad(min_cam_v_degrees)
	var max_cam_v = deg_to_rad(max_cam_v_degrees)
	camrot_v = min_cam_v + ((max_cam_v - min_cam_v) * v_ratio)
	if not is_inside_tree(): return
	$h/v.position.z = min_forward_slide + ((max_forward_slide - min_forward_slide) * v_ratio) 
	$h.rotation.y += (camrot_h - $h.rotation.y) * delta * h_acceleration
	$h/v.rotation.x += (camrot_v - $h/v.rotation.x) * delta * v_acceleration
	$h/v/Arm.spring_length = -(min_spring_length + ((max_spring_length - min_spring_length) * v_ratio))
	$h/v/Arm/Camera3D.fov = min_fov + ((max_fov - min_fov) * v_ratio)

func _joystick_input():
	if (Input.is_action_pressed("look_up") ||  Input.is_action_pressed("look_down") ||  Input.is_action_pressed("look_left") ||  Input.is_action_pressed("look_right")):
		
		joyview.x = Input.get_action_strength("look_left") - Input.get_action_strength("look_right")
		joyview.y = Input.get_action_strength("look_up") - Input.get_action_strength("look_down")
		camrot_h += joyview.x * joystick_sensitivity * h_sensitivity
		camrot_v += joyview.y * joystick_sensitivity * v_sensitivity 

func _physics_process(delta):
	# JoyPad Controls
	_joystick_input()
	var min_cam_v : float = deg_to_rad(min_cam_v_degrees)
	var max_cam_v : float = deg_to_rad(max_cam_v_degrees)
	var ratio :=  (camrot_v - min_cam_v) / (max_cam_v - min_cam_v)
	ratio = clamp(ratio, 0, 1)
	_update_camera_position(delta, ratio)
