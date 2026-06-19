extends Hazard

@export var rise_speed: float = 20.0       # px/sec during rising phase
@export var rise_target: float = -200.0    # Y position when fully risen

@onready var lava_body: Node2D = $LavaBody

var _base_y: float = 0.0
var _rising: bool = false


func _on_ready() -> void:
	_base_y = position.y
	var area := $HitArea as Area2D
	if area:
		area.body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	super._process(delta)
	if _rising and _is_active:
		position.y = maxf(position.y - rise_speed * delta, rise_target)
	elif not _rising:
		position.y = minf(position.y + rise_speed * 0.5 * delta, _base_y)


func _on_activate() -> void:
	_rising = true


func _on_deactivate() -> void:
	_rising = false


func _on_reset() -> void:
	position.y = _base_y
	_rising = false


func _on_body_entered(body: Node) -> void:
	if not _is_active:
		return
	if body.has_method("set_drive_input"):
		# Lava kills
		if body.has_method("_die"):
			body._die(9999.0)
		AudioManager.play_sfx("explosion")
