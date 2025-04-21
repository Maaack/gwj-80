class_name DeliveryInteractable
extends Node3D

signal interacted

var is_cooldown : bool = false

@onready var timer_icon: Sprite3D = %TimerIcon
@onready var cooldown_timer: Timer = %CooldownTimer
@onready var cooldown_label: Label3D = %CooldownLabel


func _process(delta: float) -> void:
	if cooldown_label.visible:
		cooldown_label.text = "%0.1f" % cooldown_timer.time_left


func _on_area_3d_body_entered(body):
	if body is PlayerCharacter:
		body.interactable = self

func _on_area_3d_body_exited(body):
	if body is PlayerCharacter:
		if body.interactable == self:
			body.interactable = null

func interact():
	if is_cooldown: return
	$Area3D/CollisionShape3D.disabled = true
	interacted.emit()
	$CooldownTimer.start()
	cooldown_label.show()
	timer_icon.show()
	is_cooldown = true

func _on_cooldown_timer_timeout():
	is_cooldown = false
	cooldown_label.hide()
	timer_icon.hide()
	$Area3D/CollisionShape3D.disabled = false
