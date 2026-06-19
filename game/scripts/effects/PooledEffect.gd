extends Node2D
class_name PooledEffect

# Base class for pooled particle/animation effects

@onready var _anim: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null
@onready var _particles: GPUParticles2D = $GPUParticles2D if has_node("GPUParticles2D") else null


func activate() -> void:
	visible = true
	if _particles:
		_particles.restart()
		_particles.emitting = true
	if _anim:
		_anim.play("activate")
	_on_activate()
	# Auto-deactivate after effect duration
	var timer := get_tree().create_timer(_get_duration())
	timer.timeout.connect(deactivate)


func deactivate() -> void:
	visible = false
	if _particles:
		_particles.emitting = false
	_on_deactivate()


func _get_duration() -> float:
	return 1.0


func _on_activate() -> void:
	pass


func _on_deactivate() -> void:
	pass
