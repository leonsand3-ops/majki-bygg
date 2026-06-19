extends Node

# Magnetic arena — periodically reverses gravity direction for all vehicles

@export var flip_interval: float = 8.0
@export var flip_duration: float = 3.0     # How long inverted gravity lasts
@export var magnetic_force: float = 1800.0  # Attractive/repulsive impulse

var _timer: float = 0.0
var _flipped: bool = false
var _flip_timer: float = 0.0
var _vehicles: Array[Node] = []

# Pole positions for magnetic force (set at arena center +/- offset)
var _left_pole_pos: Vector2 = Vector2(-650, 0)
var _right_pole_pos: Vector2 = Vector2(650, 0)
var _pole_polarity: int = 1  # 1 = attract to left, -1 = attract to right


func _ready() -> void:
	GameManager.round_started.connect(_on_round_started)


func _physics_process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING:
		return

	_timer -= delta
	if _timer <= 0.0:
		_timer = flip_interval + randf_range(-1.0, 1.0)
		_trigger_gravity_flip()

	if _flipped:
		_flip_timer -= delta
		if _flip_timer <= 0.0:
			_restore_gravity()

	# Apply periodic magnetic pull toward active pole
	_apply_magnetic_force(delta)


func _trigger_gravity_flip() -> void:
	_flipped = true
	_flip_timer = flip_duration
	_pole_polarity *= -1

	# Invert gravity for all vehicles
	for arena_child in get_parent().get_children():
		if arena_child.has_method("set_drive_input"):
			_vehicles.append(arena_child)
			arena_child.gravity_scale = -arena_child.gravity_scale
			for child in arena_child.get_children():
				if child is RigidBody2D:
					child.gravity_scale = -child.gravity_scale


func _restore_gravity() -> void:
	_flipped = false
	for v in _vehicles:
		if is_instance_valid(v):
			v.gravity_scale = absf(v.gravity_scale)
			for child in v.get_children():
				if child is RigidBody2D:
					child.gravity_scale = absf(child.gravity_scale)
	_vehicles.clear()


func _apply_magnetic_force(delta: float) -> void:
	var target_pole := _left_pole_pos if _pole_polarity == 1 else _right_pole_pos
	for arena_child in get_parent().get_children():
		if arena_child is RigidBody2D and arena_child.has_method("set_drive_input"):
			var dir := (target_pole - arena_child.global_position).normalized()
			arena_child.apply_central_force(dir * magnetic_force * 0.1)


func _on_round_started() -> void:
	_timer = flip_interval
	_flipped = false
	_vehicles.clear()
