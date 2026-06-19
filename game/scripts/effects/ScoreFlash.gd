extends PooledEffect

@onready var label: Label = $Label


func show_text(text: String) -> void:
	if label:
		label.text = text
	activate()


func _on_activate() -> void:
	modulate.a = 1.0
	var tween := create_tween()
	tween.tween_property(self, "position:y", position.y - 60.0, 0.8)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.8).set_delay(0.3)


func _get_duration() -> float:
	return 0.9
