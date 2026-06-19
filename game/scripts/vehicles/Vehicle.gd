extends RigidBody2D

# Vehicle physics body — wheels provide torque via PinJoint2D, head is the kill hitbox

signal head_hit(vehicle: Node, impact_force: float)
signal destroyed

@export var player_id: int = 0
@export var stats: Resource  # VehicleStats resource

const BASE_TORQUE := 900.0
const MAX_WHEEL_AV := 45.0
# Minimum relative velocity on head to count as a kill
const HEAD_KILL_THRESHOLD := 100.0

@onready var front_wheel: RigidBody2D = $FrontWheel
@onready var rear_wheel: RigidBody2D = $RearWheel
@onready var head_node: Node2D = $DriverHead
@onready var head_area: Area2D = $DriverHead/HeadArea
@onready var body_sprite: ColorRect = $BodySprite
@onready var driver_sprite: ColorRect = $DriverHead/DriverSprite
@onready var helmet_sprite: ColorRect = $DriverHead/HelmetSprite

var _drive_input: float = 0.0
var _is_alive: bool = true
var _spawn_position: Vector2
var _spawn_rotation: float
var _respawn_pending: bool = false


func _ready() -> void:
	_spawn_position = global_position
	_spawn_rotation = global_rotation

	head_area.body_entered.connect(_on_head_body_entered)

	if stats and stats.get("mass"):
		mass = stats.get("mass")

	_apply_player_colors()
	set_meta("player_id", player_id)

	# Also tag wheels with player_id so they don't self-trigger
	for wheel in [front_wheel, rear_wheel]:
		if wheel:
			wheel.set_meta("player_id", player_id)


func _physics_process(_delta: float) -> void:
	if not _is_alive or _respawn_pending:
		return
	_apply_wheel_torque()
	_spawn_dust_on_ground()


func _apply_wheel_torque() -> void:
	var torque_mult := 1.0
	if stats and stats.get("acceleration"):
		torque_mult = stats.get("acceleration")

	for wheel in [front_wheel, rear_wheel]:
		if not is_instance_valid(wheel):
			continue
		var av := wheel.angular_velocity
		# Only apply torque if wheel isn't already over max speed in drive direction
		if absf(av) < MAX_WHEEL_AV or (av > 0.0) != (_drive_input > 0.0):
			wheel.apply_torque(_drive_input * BASE_TORQUE * torque_mult)


func _spawn_dust_on_ground() -> void:
	# Spawn dust when wheel speed is high and vehicle is moving
	if absf(_drive_input) > 0.1 and linear_velocity.length() > 60.0:
		if randf() < 0.05:
			EffectsManager.spawn_dust(global_position + Vector2(0, 20))


func set_drive_input(value: float) -> void:
	_drive_input = clampf(value, -1.0, 1.0)


func set_spawn_transform(pos: Vector2, rot: float) -> void:
	_spawn_position = pos
	_spawn_rotation = rot
	global_position = pos
	global_rotation = rot
	if front_wheel:
		front_wheel.global_position = pos + Vector2(48, 18).rotated(rot)
		front_wheel.global_rotation = rot
	if rear_wheel:
		rear_wheel.global_position = pos + Vector2(-48, 18).rotated(rot)
		rear_wheel.global_rotation = rot


func respawn() -> void:
	_is_alive = true
	_drive_input = 0.0
	_respawn_pending = false
	# Use call_deferred to reset physics safely
	set_deferred("linear_velocity", Vector2.ZERO)
	set_deferred("angular_velocity", 0.0)
	set_deferred("global_position", _spawn_position)
	set_deferred("global_rotation", _spawn_rotation)

	for wheel in [front_wheel, rear_wheel]:
		if is_instance_valid(wheel):
			wheel.set_deferred("linear_velocity", Vector2.ZERO)
			wheel.set_deferred("angular_velocity", 0.0)

	# Restore visual state
	modulate.a = 1.0
	if head_node:
		head_node.visible = true


func _on_head_body_entered(body: Node) -> void:
	if not _is_alive:
		return

	# Only react to bodies belonging to another vehicle (tagged with player_id)
	if not body.has_meta("player_id"):
		return
	if body.get_meta("player_id") == player_id:
		return

	# Calculate impact force from relative velocities
	var my_vel := linear_velocity
	var other_vel := body.linear_velocity if body is RigidBody2D else Vector2.ZERO
	var impact := (other_vel - my_vel).length()

	if impact >= HEAD_KILL_THRESHOLD:
		_die(impact)
	else:
		# Near-miss feedback
		EffectsManager.spawn_sparks(head_node.global_position)


func _die(impact_force: float) -> void:
	_is_alive = false
	_drive_input = 0.0
	_respawn_pending = true

	head_hit.emit(self, impact_force)
	destroyed.emit()

	AudioManager.play_sfx("head_hit")
	EffectsManager.spawn_explosion(head_node.global_position if head_node else global_position)

	# Dramatic death tween
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4).set_delay(0.3)

	GameManager.report_kill(player_id)


func _apply_player_colors() -> void:
	var p1_color := Color(0.18, 0.55, 0.9, 1)
	var p2_color := Color(0.9, 0.25, 0.15, 1)
	var body_color := p1_color if player_id == 0 else p2_color
	var helmet_color := Color(0.1, 0.35, 0.65, 1) if player_id == 0 else Color(0.65, 0.1, 0.05, 1)

	if body_sprite:
		body_sprite.color = body_color
	if helmet_sprite:
		helmet_sprite.color = helmet_color
