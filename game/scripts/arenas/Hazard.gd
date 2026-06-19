extends Node2D
class_name Hazard

# Base hazard — all arena hazards extend this

@export var damage_on_touch: bool = true
@export var kill_on_touch: bool = false
@export var activation_delay: float = 0.0
@export var cycle_on: float = 2.0
@export var cycle_off: float = 1.0
@export var starts_active: bool = true

var _is_active: bool = false
var _cycle_timer: float = 0.0
var _in_on_phase: bool = true


func _ready() -> void:
	if activation_delay > 0.0:
		await get_tree().create_timer(activation_delay).timeout
	_is_active = starts_active
	_in_on_phase = starts_active
	_cycle_timer = cycle_on if starts_active else cycle_off
	_on_ready()


func _process(delta: float) -> void:
	if not _is_active and activation_delay == 0.0:
		return
	_cycle_timer -= delta
	if _cycle_timer <= 0.0:
		_in_on_phase = not _in_on_phase
		_cycle_timer = cycle_on if _in_on_phase else cycle_off
		if _in_on_phase:
			activate_hazard()
		else:
			deactivate_hazard()


func activate_hazard() -> void:
	_is_active = true
	_on_activate()


func deactivate_hazard() -> void:
	_is_active = false
	_on_deactivate()


func reset_hazard() -> void:
	_is_active = starts_active
	_in_on_phase = starts_active
	_cycle_timer = cycle_on if starts_active else cycle_off
	_on_reset()


func _on_ready() -> void:
	pass

func _on_activate() -> void:
	pass

func _on_deactivate() -> void:
	pass

func _on_reset() -> void:
	pass


func _apply_to_vehicle(vehicle: Node) -> void:
	if kill_on_touch:
		if vehicle.has_method("_die"):
			vehicle._die(9999.0)
	elif damage_on_touch:
		# Could apply damage, knockback, etc.
		if vehicle is RigidBody2D:
			var dir := (vehicle.global_position - global_position).normalized()
			vehicle.apply_central_impulse(dir * 500.0)
			EffectsManager.spawn_sparks(vehicle.global_position)
