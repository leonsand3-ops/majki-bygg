extends Hazard

@export var extend_speed: float = 400.0
@export var retract_speed: float = 200.0
@export var extend_distance: float = 60.0

@onready var spikes: Node2D = $Spikes
@onready var hit_area: Area2D = $HitArea

var _origin_y: float = 0.0
var _extending: bool = false


func _on_ready() -> void:
	if spikes:
		_origin_y = spikes.position.y
	if hit_area:
		hit_area.body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	super._process(delta)
	if not spikes:
		return

	if _extending and _is_active:
		spikes.position.y = maxf(
			spikes.position.y - extend_speed * delta,
			_origin_y - extend_distance
		)
	else:
		spikes.position.y = minf(
			spikes.position.y + retract_speed * delta,
			_origin_y
		)


func _on_activate() -> void:
	_extending = true


func _on_deactivate() -> void:
	_extending = false


func _on_reset() -> void:
	_extending = false
	if spikes:
		spikes.position.y = _origin_y


func _on_body_entered(body: Node) -> void:
	if not _is_active:
		return
	var spike_y: float = spikes.position.y if spikes else _origin_y
	if spike_y > _origin_y - extend_distance * 0.5:
		return  # Not extended enough
	if body.has_method("set_drive_input"):
		_apply_to_vehicle(body)
		AudioManager.play_sfx("impact")
