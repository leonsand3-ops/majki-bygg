extends Control

@onready var btn_play: Button = $VBoxContainer/BtnPlay
@onready var btn_versus: Button = $VBoxContainer/BtnVersus
@onready var btn_practice: Button = $VBoxContainer/BtnPractice
@onready var btn_options: Button = $VBoxContainer/BtnOptions
@onready var btn_quit: Button = $VBoxContainer/BtnQuit
@onready var arena_selector: HBoxContainer = $VBoxContainer/ArenaSelector
@onready var arena_label: Label = $VBoxContainer/ArenaSelector/ArenaLabel

var _selected_arena: int = 0
const ARENA_NAMES := [
	"Classic Bowl",
	"Central Sawblade",
	"Rising Lava",
	"Collapsing Floor",
	"Magnetic Arena",
]


func _ready() -> void:
	btn_play.pressed.connect(_on_play_pressed)
	btn_versus.pressed.connect(_on_versus_pressed)
	btn_practice.pressed.connect(_on_practice_pressed)
	btn_options.pressed.connect(_on_options_pressed)
	btn_quit.pressed.connect(_on_quit_pressed)

	var btn_prev: Button = $VBoxContainer/ArenaSelector/BtnPrev
	var btn_next: Button = $VBoxContainer/ArenaSelector/BtnNext
	if btn_prev:
		btn_prev.pressed.connect(_prev_arena)
	if btn_next:
		btn_next.pressed.connect(_next_arena)

	_update_arena_label()
	AudioManager.play_music("res://assets/audio/music_menu.ogg")


func _on_play_pressed() -> void:
	AudioManager.play_sfx("button_click")
	_start_game(GameManager.GameMode.VERSUS)


func _on_versus_pressed() -> void:
	AudioManager.play_sfx("button_click")
	_start_game(GameManager.GameMode.VERSUS)


func _on_practice_pressed() -> void:
	AudioManager.play_sfx("button_click")
	_start_game(GameManager.GameMode.VS_AI)


func _on_options_pressed() -> void:
	AudioManager.play_sfx("button_click")
	get_tree().change_scene_to_file("res://scenes/ui/OptionsMenu.tscn")


func _on_quit_pressed() -> void:
	AudioManager.play_sfx("button_click")
	get_tree().quit()


func _start_game(mode: GameManager.GameMode) -> void:
	get_tree().change_scene_to_file("res://scenes/Game.tscn")
	await get_tree().process_frame
	GameManager.start_match(mode, _selected_arena)


func _prev_arena() -> void:
	_selected_arena = (_selected_arena - 1 + ARENA_NAMES.size()) % ARENA_NAMES.size()
	_update_arena_label()


func _next_arena() -> void:
	_selected_arena = (_selected_arena + 1) % ARENA_NAMES.size()
	_update_arena_label()


func _update_arena_label() -> void:
	if arena_label:
		arena_label.text = ARENA_NAMES[_selected_arena]


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		SettingsManager.toggle_fullscreen()
