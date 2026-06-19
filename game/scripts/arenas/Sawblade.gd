extends Hazard

@export var spin_speed: float = 200.0  # degrees/sec
@export var move_path: Curve2D = null
@export var move_speed: float = 80.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var hit_area: Area2D = $HitArea

var _path_t: float = 0.0
var _path_length: float = 0.0


func _on_ready() -> void:
	if hit_area:
		hit_area.body_entered.connect(_on_body_entered)
	if move_path:
		_path_length = move_path.get_baked_length()


func _process(delta: float) -> void:
	super._process(delta)
	if sprite:
		sprite.rotation_degrees += spin_speed * delta

	if move_path and _path_length > 0.0 and _is_active:
		_path_t += move_speed * delta / _path_length
		if _path_t >= 1.0:
			_path_t = fmod(_path_t, 1.0)
		position = move_path.sample_baked(_path_t * _path_length)


func _on_body_entered(body: Node) -> void:
	if not _is_active:
		return
	if body.has_method("set_drive_input"):
		_apply_to_vehicle(body)
		AudioManager.play_sfx("impact")
		EffectsManager.spawn_sparks(global_position)


func _on_activate() -> void:
	if hit_area:
		hit_area.monitoring = true
	modulate = Color.WHITE


func _on_deactivate() -> void:
	if hit_area:
		hit_area.monitoring = false
	modulate = Color(1, 1, 1, 0.3)
