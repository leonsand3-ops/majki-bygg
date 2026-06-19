extends Node

# Randomly collapses floor tiles after a delay, then resets them

@export var collapse_delay: float = 5.0
@export var warning_flash_count: int = 4
@export var tile_fall_speed: float = 300.0

var _tiles: Array[Node] = []
var _tile_original_pos: Dictionary = {}
var _tile_alive: Array[bool] = []
var _collapse_timer: float = 0.0
var _reset_pending: bool = false


func _ready() -> void:
	var floor_node := get_parent().get_node_or_null("FloorTiles")
	if not floor_node:
		return
	for child in floor_node.get_children():
		if child is StaticBody2D:
			_tiles.append(child)
			_tile_original_pos[child] = child.position
			_tile_alive.append(true)

	GameManager.round_started.connect(_on_round_started)

	# Wire kill floor
	var kf := get_parent().get_node_or_null("KillFloor")
	if kf:
		kf.body_entered.connect(_on_kill_floor_body_entered)


func _process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING:
		return
	_collapse_timer -= delta
	if _collapse_timer <= 0.0:
		_collapse_timer = randf_range(1.5, 4.0)
		_trigger_random_collapse()


func _trigger_random_collapse() -> void:
	var alive_indices: Array[int] = []
	for i in _tile_alive.size():
		if _tile_alive[i]:
			alive_indices.append(i)
	if alive_indices.is_empty():
		return

	var idx: int = alive_indices[randi() % alive_indices.size()]
	var tile: Node = _tiles[idx]
	_tile_alive[idx] = false
	_collapse_tile(tile)


func _collapse_tile(tile: Node) -> void:
	# Flash warning
	var tween := tile.create_tween()
	for i in warning_flash_count:
		tween.tween_property(tile, "modulate", Color(1, 0.2, 0.2, 1), 0.1)
		tween.tween_property(tile, "modulate", Color.WHITE, 0.1)

	# Then fall
	tween.tween_property(tile, "position:y", tile.position.y + 600.0, 0.5).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): tile.collision_layer = 0)  # Disable collision


func _on_round_started() -> void:
	_collapse_timer = collapse_delay
	_restore_all_tiles()


func _restore_all_tiles() -> void:
	for i in _tiles.size():
		var tile := _tiles[i]
		tile.position = _tile_original_pos[tile]
		tile.modulate = Color.WHITE
		tile.set_collision_layer(1)
		_tile_alive[i] = true


func _on_kill_floor_body_entered(body: Node) -> void:
	if body.has_method("set_drive_input"):
		if body.has_method("_die"):
			body._die(9999.0)
