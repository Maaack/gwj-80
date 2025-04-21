class_name QuestGiver
extends StaticBody3D


signal interacted


func _on_area_3d_body_entered(body):
	if body is PlayerCharacter:
		body.interactable = self


func _on_area_3d_body_exited(body):
	if body is PlayerCharacter:
		if body.interactable == self:
			body.interactable = null


func interact():
	interacted.emit()
