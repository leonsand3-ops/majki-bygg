extends CanvasLayer

@onready var p1_score: Label = $MarginContainer/HBoxContainer/P1Score
@onready var p2_score: Label = $MarginContainer/HBoxContainer/P2Score
@onready var round_label: Label = $MarginContainer/HBoxContainer/RoundLabel
@onready var countdown_label: Label = $CountdownLabel
@onready var message_label: Label = $MessageLabel

var _message_timer: float = 0.0
var _countdown_running: bool = false


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.round_started.connect(_on_round_started)
	GameManager.round_ended.connect(_on_round_ended)
	_update_scores(0, 0)
	countdown_label.visible = false
	message_label.visible = false


func _process(delta: float) -> void:
	if _message_timer > 0.0:
		_message_timer -= delta
		if _message_timer <= 0.0:
			message_label.visible = false


func _on_score_changed(s1: int, s2: int) -> void:
	_update_scores(s1, s2)


func _update_scores(s1: int, s2: int) -> void:
	if p1_score:
		p1_score.text = str(s1)
	if p2_score:
		p2_score.text = str(s2)
	if round_label:
		round_label.text = "Round %d" % GameManager.current_round


func _on_round_started() -> void:
	if round_label:
		round_label.text = "Round %d" % GameManager.current_round
	if not _countdown_running:
		_start_countdown()


func _start_countdown() -> void:
	_countdown_running = true
	countdown_label.visible = true

	for i in range(3, 0, -1):
		countdown_label.text = str(i)
		countdown_label.modulate = Color.WHITE
		# Pulse animation
		var tween := create_tween()
		tween.tween_property(countdown_label, "scale", Vector2(1.3, 1.3), 0.0)
		tween.tween_property(countdown_label, "scale", Vector2(1.0, 1.0), 0.5)
		AudioManager.play_sfx("countdown")
		await get_tree().create_timer(1.0).timeout

	countdown_label.text = "GO!"
	countdown_label.modulate = Color(0.3, 1.0, 0.4, 1)
	AudioManager.play_sfx("round_start")
	GameManager.set_playing()
	await get_tree().create_timer(0.7).timeout
	countdown_label.visible = false
	_countdown_running = false


func _on_round_ended(winner_id: int) -> void:
	var name_str := "Player %d" % (winner_id + 1)
	var color := Color(0.2, 0.6, 1.0, 1) if winner_id == 0 else Color(1.0, 0.3, 0.2, 1)
	show_message("%s Scores!" % name_str, 2.0, color)
	AudioManager.play_sfx("impact")


func show_message(text: String, duration: float = 2.0, color: Color = Color.WHITE) -> void:
	message_label.text = text
	message_label.modulate = color
	message_label.visible = true
	_message_timer = duration
