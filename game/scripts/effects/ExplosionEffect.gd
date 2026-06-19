extends PooledEffect

func _on_activate() -> void:
	# Scale punch for impact feel
	scale = Vector2(0.1, 0.1)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.15).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)


func _get_duration() -> float:
	return 0.8
