extends Node

# Central game state controller — singleton autoloaded as GameManager

signal round_started
signal round_ended(winner_id: int)
signal match_ended(winner_id: int)
signal score_changed(p1_score: int, p2_score: int)
signal arena_loaded

enum GameState { MENU, COUNTDOWN, PLAYING, ROUND_END, MATCH_END }
enum GameMode { VERSUS, PRACTICE, VS_AI }

const POINTS_TO_WIN := 5
const ARENAS := [
	"res://scenes/arenas/Arena1_Bowl.tscn",
	"res://scenes/arenas/Arena2_Sawblade.tscn",
	"res://scenes/arenas/Arena3_Lava.tscn",
	"res://scenes/arenas/Arena4_Collapse.tscn",
	"res://scenes/arenas/Arena5_Magnetic.tscn",
]

var state: GameState = GameState.MENU
var mode: GameMode = GameMode.VERSUS
var scores: Array[int] = [0, 0]
var current_round: int = 0
var current_arena_index: int = 0
var current_arena: Node = null
var ai_difficulty: int = 1  # 0=Easy 1=Medium 2=Hard

var _game_scene: Node = null


func start_match(game_mode: GameMode, arena_index: int = 0) -> void:
	mode = game_mode
	scores = [0, 0]
	current_round = 0
	current_arena_index = arena_index
	_load_arena()


func _load_arena() -> void:
	var arena_path: String = ARENAS[current_arena_index]
	var packed: PackedScene = load(arena_path)
	if current_arena:
		current_arena.queue_free()
	current_arena = packed.instantiate()
	_game_scene.add_child(current_arena)
	arena_loaded.emit()
	start_round()


func start_round() -> void:
	current_round += 1
	state = GameState.COUNTDOWN
	round_started.emit()


func report_kill(victim_player_id: int) -> void:
	if state != GameState.PLAYING:
		return
	var scorer := 1 if victim_player_id == 0 else 0
	scores[scorer] += 1
	score_changed.emit(scores[0], scores[1])
	state = GameState.ROUND_END
	round_ended.emit(scorer)

	if scores[scorer] >= POINTS_TO_WIN:
		await get_tree().create_timer(2.0).timeout
		state = GameState.MATCH_END
		match_ended.emit(scorer)
	else:
		await get_tree().create_timer(2.5).timeout
		_reset_round()


func _reset_round() -> void:
	if current_arena and current_arena.has_method("reset"):
		current_arena.reset()
	start_round()


func return_to_menu() -> void:
	state = GameState.MENU
	scores = [0, 0]
	current_round = 0
	if current_arena:
		current_arena.queue_free()
		current_arena = null
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func set_playing() -> void:
	state = GameState.PLAYING


func register_game_scene(node: Node) -> void:
	_game_scene = node
