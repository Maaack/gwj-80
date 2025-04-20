class_name Notification
extends PanelContainer


var position_tween: Tween
var fade_tween: Tween

@onready var icon: TextureRect = %Icon
@onready var message: Label = %Message


func tween_position(new_position: Vector2, duration: float) -> void:
	if position_tween and position_tween.is_running():
		position_tween.kill()

	position_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	position_tween.tween_property(self, "position", new_position, duration)


func _tween_fade(duration: float) -> void:
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()

	fade_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	fade_tween.tween_property(self, "modulate:a", 0.0, duration)
	fade_tween.tween_callback(queue_free)


func _on_lifetime_timer_timeout() -> void:
	_tween_fade(1.0)
