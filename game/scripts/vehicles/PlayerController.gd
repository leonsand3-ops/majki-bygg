extends Node
class_name PlayerController

# Reads keyboard input and drives the attached vehicle

@export var vehicle: NodePath
@export var player_id: int = 0

var _vehicle_node: Node
var _left_action: StringName
var _right_action: StringName


func _ready() -> void:
	_vehicle_node = get_node(vehicle) if not vehicle.is_empty() else get_parent()
	_left_action = "p1_left" if player_id == 0 else "p2_left"
	_right_action = "p1_right" if player_id == 0 else "p2_right"


func _process(_delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING:
		_vehicle_node.set_drive_input(0.0)
		return

	var input := 0.0
	if Input.is_action_pressed(_left_action):
		input -= 1.0
	if Input.is_action_pressed(_right_action):
		input += 1.0

	_vehicle_node.set_drive_input(input)
