extends Node2D
class_name Arena

# Base arena class — all arenas extend this

signal hazard_triggered(hazard: Node)

@export var spawn_positions: Array[Vector2] = [
	Vector2(-300, -100),
	Vector2(300, -100),
]
@export var spawn_rotations: Array[float] = [0.0, 180.0]
@export var arena_name: String = "Arena"

var _vehicles: Array[Node] = []
var _hazards: Array[Node] = []


func _ready() -> void:
	_collect_hazards()


func _collect_hazards() -> void:
	for child in get_children():
		if child.has_method("activate_hazard"):
			_hazards.append(child)


func setup_vehicles(vehicles: Array[Node]) -> void:
	_vehicles = vehicles
	for i in mini(vehicles.size(), spawn_positions.size()):
		var v := vehicles[i]
		if v.has_method("set_spawn_transform"):
			v.set_spawn_transform(
				global_position + spawn_positions[i],
				deg_to_rad(spawn_rotations[i])
			)


func reset() -> void:
	for v in _vehicles:
		if is_instance_valid(v) and v.has_method("respawn"):
			v.respawn()
	for h in _hazards:
		if is_instance_valid(h) and h.has_method("reset_hazard"):
			h.reset_hazard()
	_on_reset()


func _on_reset() -> void:
	pass  # Override in subclasses


func get_spawn_position(player_id: int) -> Vector2:
	if player_id < spawn_positions.size():
		return global_position + spawn_positions[player_id]
	return global_position
