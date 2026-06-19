extends Node

# Audio singleton — plays sounds and manages volume buses

const BUS_MASTER := "Master"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"

# Placeholder paths — replace with real audio files
const SOUNDS := {
	"engine": "res://assets/audio/engine.wav",
	"impact": "res://assets/audio/impact.wav",
	"head_hit": "res://assets/audio/head_hit.wav",
	"explosion": "res://assets/audio/explosion.wav",
	"button_click": "res://assets/audio/button_click.wav",
	"victory": "res://assets/audio/victory.wav",
	"countdown": "res://assets/audio/countdown.wav",
	"round_start": "res://assets/audio/round_start.wav",
}

var _music_player: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
const POOL_SIZE := 8
var _pool_index := 0


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = BUS_MUSIC
	add_child(_music_player)

	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		p.bus = BUS_SFX
		add_child(p)
		_sfx_pool.append(p)

	_ensure_buses()


func _ensure_buses() -> void:
	for bus_name in [BUS_MUSIC, BUS_SFX]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.get_bus_count() - 1, bus_name)
			AudioServer.set_bus_send(AudioServer.get_bus_count() - 1, BUS_MASTER)


func play_sfx(sound_name: String, pitch_scale: float = 1.0) -> void:
	var path: String = SOUNDS.get(sound_name, "")
	if path.is_empty():
		return
	if not ResourceLoader.exists(path):
		return
	var player := _sfx_pool[_pool_index]
	_pool_index = (_pool_index + 1) % POOL_SIZE
	player.stream = load(path)
	player.pitch_scale = pitch_scale
	player.play()


func play_music(path: String, loop: bool = true) -> void:
	if not ResourceLoader.exists(path):
		return
	_music_player.stream = load(path)
	if _music_player.stream is AudioStream:
		_music_player.play()


func stop_music() -> void:
	_music_player.stop()


func set_bus_volume(bus_name: String, linear_volume: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(linear_volume))


func get_bus_volume(bus_name: String) -> float:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		return db_to_linear(AudioServer.get_bus_volume_db(idx))
	return 1.0
