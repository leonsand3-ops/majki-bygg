extends AnimatableBody2D

@export var point_a: Vector2 = Vector2(-200, 0)
@export var point_b: Vector2 = Vector2(200, 0)
@export var speed: float = 100.0
@export var wait_time: float = 0.5

var _going_to_b: bool = true
var _waiting: float = 0.0
var _start_pos: Vector2


func _ready() -> void:
	_start_pos = position


func _physics_process(delta: float) -> void:
	if _waiting > 0.0:
		_waiting -= delta
		return

	var target := _start_pos + (point_b if _going_to_b else point_a)
	var dir := (target - global_position).normalized()
	var move := dir * speed * delta
	var dist := global_position.distance_to(target)

	if dist <= speed * delta:
		global_position = target
		_going_to_b = not _going_to_b
		_waiting = wait_time
	else:
		global_position += move
