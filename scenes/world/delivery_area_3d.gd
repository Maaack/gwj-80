class_name DeliveryArea3D
extends Area3D

signal slime_delivered(slime_data : SlimeData)
signal slime_detected

@export var cooldown_time : float = 0.1
@export var delivery_time : float = 1.0

var slimes_detected : Array[Slime]

func deliver_slime(slime : Slime) -> void:
	var slime_data = slime.slime_data
	slime.depart(delivery_time)
	await slime.departed
	slime_delivered.emit(slime_data)

func deliver() -> void:
	if slimes_detected.size() == 0: return
	for slime in slimes_detected:
		deliver_slime(slime)
		await get_tree().create_timer(cooldown_time, false).timeout

func _on_body_entered(body : Node3D):
	if body is Slime:
		slimes_detected.append(body)
		slime_detected.emit()

func _on_body_exited(body : Node3D):
	if body is Slime and body in slimes_detected:
		slimes_detected.erase(body)

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
