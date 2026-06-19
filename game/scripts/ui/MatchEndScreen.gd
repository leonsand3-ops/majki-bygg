extends Control

@onready var winner_label: Label = $VBoxContainer/WinnerLabel
@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var btn_rematch: Button = $VBoxContainer/BtnRematch
@onready var btn_menu: Button = $VBoxContainer/BtnMenu


func _ready() -> void:
	GameManager.match_ended.connect(_on_match_ended)
	btn_rematch.pressed.connect(_on_rematch)
	btn_menu.pressed.connect(_on_menu)
	visible = false


func _on_match_ended(winner_id: int) -> void:
	winner_label.text = "Player %d Wins!" % (winner_id + 1)
	winner_label.modulate = Color(0.2, 0.6, 1.0, 1) if winner_id == 0 else Color(1.0, 0.3, 0.2, 1)
	score_label.text = "%d  —  %d" % [GameManager.scores[0], GameManager.scores[1]]
	visible = true
	AudioManager.play_sfx("victory")
	AudioManager.stop_music()

	# Entrance animation
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)


func _on_rematch() -> void:
	AudioManager.play_sfx("button_click")
	visible = false
	GameManager.start_match(GameManager.mode, GameManager.current_arena_index)


func _on_menu() -> void:
	AudioManager.play_sfx("button_click")
	GameManager.return_to_menu()
