class_name DeliveryArea3D
extends Area3D

signal slime_delivered(slime_data : SlimeData)
signal slime_detected

@export var delivery_time : float = 1.0

var slimes_detected : Array[Slime]

func deliver():
	for slime in slimes_detected:
		var slime_data = slime.slime_data
		var tween = create_tween()
		tween.tween_property(slime, "scale", Vector3.ONE * 0.01, delivery_time)
		await tween.finished
		slime.queue_free()
		slime_delivered.emit(slime.slime_data)

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
