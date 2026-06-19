extends Node
class_name AIController

# AI vehicle controller with Easy / Medium / Hard difficulty

enum Difficulty { EASY, MEDIUM, HARD }

@export var difficulty: Difficulty = Difficulty.MEDIUM
@export var vehicle: NodePath

var _vehicle_node: Node
var _enemy: Node = null

# Timing
var _think_timer: float = 0.0
var _current_input: float = 0.0
var _mistake_timer: float = 0.0
var _making_mistake: bool = false

# Tuning per difficulty
const THINK_INTERVALS := [0.4, 0.15, 0.05]   # seconds between decisions
const MISTAKE_CHANCE  := [0.35, 0.12, 0.02]   # chance per think tick to start a mistake
const MISTAKE_DURATION := [1.2, 0.6, 0.2]     # how long mistakes last


func _ready() -> void:
	_vehicle_node = get_node(vehicle) if not vehicle.is_empty() else get_parent()


func set_enemy(enemy_vehicle: Node) -> void:
	_enemy = enemy_vehicle


func _process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING:
		_vehicle_node.set_drive_input(0.0)
		return

	_think_timer -= delta
	if _think_timer <= 0.0:
		_think_timer = THINK_INTERVALS[difficulty]
		_decide()

	if _making_mistake:
		_mistake_timer -= delta
		if _mistake_timer <= 0.0:
			_making_mistake = false

	_vehicle_node.set_drive_input(_current_input)


func _decide() -> void:
	# Chance to make a mistake (wrong direction)
	if randf() < MISTAKE_CHANCE[difficulty]:
		_making_mistake = true
		_mistake_timer = MISTAKE_DURATION[difficulty]
		_current_input = randf_range(-1.0, 1.0)
		return

	if _making_mistake:
		return

	if _enemy == null or not is_instance_valid(_enemy):
		_current_input = 0.0
		return

	match difficulty:
		Difficulty.EASY:
			_decide_easy()
		Difficulty.MEDIUM:
			_decide_medium()
		Difficulty.HARD:
			_decide_hard()


func _decide_easy() -> void:
	# Simple: move toward enemy
	var diff := _enemy.global_position.x - _vehicle_node.global_position.x
	_current_input = sign(diff)


func _decide_medium() -> void:
	# Chase enemy but also consider own tilt — protect head when flipped
	var own_rot := fmod(_vehicle_node.global_rotation_degrees + 360.0, 360.0)
	var is_flipped := own_rot > 90.0 and own_rot < 270.0

	if is_flipped:
		# Try to right ourselves by spinning
		var diff_x := _enemy.global_position.x - _vehicle_node.global_position.x
		_current_input = -sign(diff_x)
	else:
		var diff_x := _enemy.global_position.x - _vehicle_node.global_position.x
		_current_input = sign(diff_x)


func _decide_hard() -> void:
	# Predict enemy position and aim head collision
	var my_pos := _vehicle_node.global_position
	var enemy_pos := _enemy.global_position
	var enemy_vel := Vector2.ZERO
	if _enemy is RigidBody2D:
		enemy_vel = _enemy.linear_velocity

	# Predict where enemy head will be in ~0.3s
	var predicted := enemy_pos + enemy_vel * 0.3
	var diff_x := predicted.x - my_pos.x

	# Defensive: if our head is near enemy, back off and reposition
	var head_node := _vehicle_node.get_node_or_null("DriverHead")
	if head_node:
		var head_dist := head_node.global_position.distance_to(enemy_pos)
		if head_dist < 80.0:
			# Back away to avoid getting hit
			_current_input = -sign(diff_x)
			return

	_current_input = sign(diff_x)
