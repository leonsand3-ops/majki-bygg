extends Hazard

@export var crush_distance: float = 300.0
@export var crush_speed: float = 600.0
@export var retract_speed: float = 150.0
@export var warning_duration: float = 0.8

@onready var crusher_body: Node2D = $CrusherBody
@onready var hit_area: Area2D = $HitArea
@onready var warning_sprite: Sprite2D = $WarningSprite

enum Phase { IDLE, WARNING, CRUSHING, RETRACTING }
var _phase: Phase = Phase.IDLE
var _origin_y: float = 0.0
var _target_y: float = 0.0
var _warning_timer: float = 0.0


func _on_ready() -> void:
	_origin_y = crusher_body.position.y
	_target_y = _origin_y + crush_distance
	if hit_area:
		hit_area.body_entered.connect(_on_body_entered)
	if warning_sprite:
		warning_sprite.visible = false


func _process(delta: float) -> void:
	super._process(delta)
	match _phase:
		Phase.WARNING:
			_warning_timer -= delta
			if warning_sprite:
				warning_sprite.visible = fmod(_warning_timer, 0.2) > 0.1
			if _warning_timer <= 0.0:
				_phase = Phase.CRUSHING

		Phase.CRUSHING:
			crusher_body.position.y = minf(
				crusher_body.position.y + crush_speed * delta,
				_target_y
			)
			if crusher_body.position.y >= _target_y:
				_phase = Phase.RETRACTING

		Phase.RETRACTING:
			crusher_body.position.y = maxf(
				crusher_body.position.y - retract_speed * delta,
				_origin_y
			)
			if crusher_body.position.y <= _origin_y:
				_phase = Phase.IDLE
				if warning_sprite:
					warning_sprite.visible = false


func _on_activate() -> void:
	if _phase == Phase.IDLE:
		_phase = Phase.WARNING
		_warning_timer = warning_duration


func _on_deactivate() -> void:
	pass


func _on_reset() -> void:
	_phase = Phase.IDLE
	if crusher_body:
		crusher_body.position.y = _origin_y
	if warning_sprite:
		warning_sprite.visible = false


func _on_body_entered(body: Node) -> void:
	if _phase != Phase.CRUSHING:
		return
	if body.has_method("set_drive_input"):
		_apply_to_vehicle(body)
		AudioManager.play_sfx("impact")
		if EffectsManager.has_method("shake_camera"):
			EffectsManager.shake_camera(20.0)
