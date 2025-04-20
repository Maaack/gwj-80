class_name NotificationContainer
extends Control


const NOTIFICATION := preload("res://scenes/game_scene/notification.tscn")
const SLIME := preload("res://assets/Art/2d/TExtures/SLime.png")

## The offset from the top left position of its parent.
@export var position_offset := Vector2(20.0, 20.0)
## The space between its children.
@export var separation: float = 8.0


func _ready() -> void:
	# NOTE: Is this guaranteed exist before the NotificationContainer?
	GameState.get_journal_state().slime_discovered.connect(_on_slime_discovered)


func _on_slime_discovered(slime_type: Constants.SlimeType) -> void:
	var message: String = Constants.get_slime_name(slime_type) + " slime discovered!"
	create_notification(Constants.get_slime_icon(slime_type), message)


## Instantiates a new notification offscreen, moves any exisiting notifications down,
## and then moves the new notification onscreen.
func create_notification(icon: Texture2D, message: String) -> void:
	for i: int in get_children().size():
		var index_from_end: int = -(i + 1)
		var child: Notification = get_child(index_from_end)

		var previous_children_space_y: float = (child.size.y + separation) * (i + 1)
		var new_position := Vector2(position_offset.x, previous_children_space_y + position_offset.y)
		child.tween_position(new_position, 0.5)

	var notification: Notification = NOTIFICATION.instantiate()
	add_child(notification)
	notification.icon.texture = icon
	notification.message.text = message

	# The panel does not automatically shrink its size to fit the new content.
	# Setting the size to zero will cause it to be its minimum size.
	notification.size = Vector2.ZERO
	notification.position = Vector2(-notification.size.x, position_offset.y)
	notification.tween_position(position_offset, 1.0)
