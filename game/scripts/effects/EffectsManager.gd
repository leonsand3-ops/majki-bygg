extends Node

# Pools and spawns visual effects — singleton autoloaded as EffectsManager

const EFFECT_SCENES := {
	"dust": "res://scenes/effects/Dust.tscn",
	"sparks": "res://scenes/effects/Sparks.tscn",
	"explosion": "res://scenes/effects/Explosion.tscn",
	"score_flash": "res://scenes/effects/ScoreFlash.tscn",
}

const POOL_SIZE := 8
var _pools: Dictionary = {}
var _pool_indices: Dictionary = {}
var _camera: Camera2D = null


func _ready() -> void:
	for key in EFFECT_SCENES:
		_pools[key] = []
		_pool_indices[key] = 0
		var packed: PackedScene = _try_load(EFFECT_SCENES[key])
		if packed == null:
			continue
		for i in POOL_SIZE:
			var inst: Node = packed.instantiate()
			inst.process_mode = Node.PROCESS_MODE_ALWAYS
			add_child(inst)
			if inst.has_method("deactivate"):
				inst.deactivate()
			_pools[key].append(inst)


func _try_load(path: String) -> PackedScene:
	if ResourceLoader.exists(path):
		return load(path)
	return null


func register_camera(cam: Camera2D) -> void:
	_camera = cam


func _get_from_pool(effect_type: String) -> Node:
	if not _pools.has(effect_type) or _pools[effect_type].is_empty():
		return null
	var idx: int = _pool_indices[effect_type]
	_pool_indices[effect_type] = (idx + 1) % _pools[effect_type].size()
	return _pools[effect_type][idx]


func spawn_dust(position: Vector2) -> void:
	var inst := _get_from_pool("dust")
	if inst:
		inst.global_position = position
		if inst.has_method("activate"):
			inst.activate()


func spawn_sparks(position: Vector2) -> void:
	var inst := _get_from_pool("sparks")
	if inst:
		inst.global_position = position
		if inst.has_method("activate"):
			inst.activate()


func spawn_explosion(position: Vector2) -> void:
	var inst := _get_from_pool("explosion")
	if inst:
		inst.global_position = position
		if inst.has_method("activate"):
			inst.activate()
	if _camera and _camera.has_method("shake"):
		_camera.shake(25.0)


func spawn_score_flash(position: Vector2, text: String) -> void:
	var inst := _get_from_pool("score_flash")
	if inst:
		inst.global_position = position
		if inst.has_method("show_text"):
			inst.show_text(text)
