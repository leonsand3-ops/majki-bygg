extends Node2D

# Root game scene — wires up vehicles, arena, camera, and controllers

@onready var camera: Camera2D = $ArenaCamera


func _ready() -> void:
	GameManager.register_game_scene(self)
	EffectsManager.register_camera(camera)
	GameManager.arena_loaded.connect(_on_arena_loaded)


func _on_arena_loaded() -> void:
	var arena := GameManager.current_arena
	if not arena:
		return

	var vehicles: Array[Node] = []
	var mode := GameManager.mode

	for i in 2:
		var v := _spawn_vehicle(i, arena)
		vehicles.append(v)

	arena.setup_vehicles(vehicles)

	for v in vehicles:
		camera.add_target(v as Node2D)

	# Player 1 always gets keyboard controller
	var p1 := PlayerController.new()
	p1.player_id = 0
	vehicles[0].add_child(p1)

	if mode == GameManager.GameMode.VS_AI:
		var ai := AIController.new()
		ai.difficulty = AIController.Difficulty.values()[GameManager.ai_difficulty]
		vehicles[1].add_child(ai)
		ai.set_enemy(vehicles[0])
	else:
		var p2 := PlayerController.new()
		p2.player_id = 1
		vehicles[1].add_child(p2)


func _spawn_vehicle(player_id: int, parent: Node) -> Node:
	var packed: PackedScene = load("res://scenes/vehicles/Vehicle.tscn")
	var v: Node = packed.instantiate()
	v.player_id = player_id
	v.set_meta("player_id", player_id)
	parent.add_child(v)
	return v


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		SettingsManager.toggle_fullscreen()
