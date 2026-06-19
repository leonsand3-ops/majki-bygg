extends Camera2D

# Tracks midpoint between two vehicles, zooms based on distance

@export var min_zoom: float = 0.5
@export var max_zoom: float = 1.0
@export var zoom_margin: float = 200.0      # Extra padding around players
@export var follow_speed: float = 4.0
@export var zoom_speed: float = 2.0
@export var shake_decay: float = 5.0

var _targets: Array[Node2D] = []
var _shake_amount: float = 0.0
var _shake_offset: Vector2 = Vector2.ZERO
var _base_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	make_current()


func _physics_process(delta: float) -> void:
	if _targets.is_empty():
		return

	var mid := _calc_midpoint()
	var desired_zoom := _calc_zoom()

	_base_position = _base_position.lerp(mid, follow_speed * delta)
	var current_zoom_val := lerp(zoom.x, desired_zoom, zoom_speed * delta)
	zoom = Vector2(current_zoom_val, current_zoom_val)

	# Camera shake
	if _shake_amount > 0.0:
		_shake_amount = lerpf(_shake_amount, 0.0, shake_decay * delta)
		_shake_offset = Vector2(
			randf_range(-_shake_amount, _shake_amount),
			randf_range(-_shake_amount, _shake_amount)
		)
	else:
		_shake_offset = Vector2.ZERO

	global_position = _base_position + _shake_offset


func add_target(node: Node2D) -> void:
	if node not in _targets:
		_targets.append(node)


func remove_target(node: Node2D) -> void:
	_targets.erase(node)


func shake(amount: float) -> void:
	_shake_amount = maxf(_shake_amount, amount)


func _calc_midpoint() -> Vector2:
	if _targets.size() == 1:
		return _targets[0].global_position

	var sum := Vector2.ZERO
	var valid := 0
	for t in _targets:
		if is_instance_valid(t):
			sum += t.global_position
			valid += 1
	if valid == 0:
		return global_position
	return sum / float(valid)


func _calc_zoom() -> float:
	if _targets.size() < 2:
		return max_zoom

	var pos_a := _targets[0].global_position
	var pos_b := _targets[1].global_position
	var dist := pos_a.distance_to(pos_b)
	var required_size := dist + zoom_margin * 2.0
	# viewport size / required_size gives us the zoom factor needed
	var viewport_size := get_viewport_rect().size
	var zoom_needed := minf(viewport_size.x, viewport_size.y) / required_size
	return clampf(zoom_needed, min_zoom, max_zoom)
