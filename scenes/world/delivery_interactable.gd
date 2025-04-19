class_name DeliveryInteractable
extends Node3D

signal interacted

var is_cooldown : bool = false

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
	is_cooldown = true

func _on_cooldown_timer_timeout():
	is_cooldown = false
	$Area3D/CollisionShape3D.disabled = false
