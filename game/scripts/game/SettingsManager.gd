extends Node

const CONFIG_PATH := "user://settings.cfg"

var _config := ConfigFile.new()

var fullscreen: bool = false
var resolution: Vector2i = Vector2i(1920, 1080)
var volume_master: float = 1.0
var volume_music: float = 0.8
var volume_sfx: float = 1.0


func _ready() -> void:
	load_settings()
	apply_settings()


func load_settings() -> void:
	var err := _config.load(CONFIG_PATH)
	if err != OK:
		return  # Use defaults

	fullscreen = _config.get_value("display", "fullscreen", false)
	resolution = _config.get_value("display", "resolution", Vector2i(1920, 1080))
	volume_master = _config.get_value("audio", "volume_master", 1.0)
	volume_music = _config.get_value("audio", "volume_music", 0.8)
	volume_sfx = _config.get_value("audio", "volume_sfx", 1.0)


func save_settings() -> void:
	_config.set_value("display", "fullscreen", fullscreen)
	_config.set_value("display", "resolution", resolution)
	_config.set_value("audio", "volume_master", volume_master)
	_config.set_value("audio", "volume_music", volume_music)
	_config.set_value("audio", "volume_sfx", volume_sfx)
	_config.save(CONFIG_PATH)


func apply_settings() -> void:
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(resolution)

	AudioManager.set_bus_volume("Master", volume_master)
	AudioManager.set_bus_volume("Music", volume_music)
	AudioManager.set_bus_volume("SFX", volume_sfx)


func toggle_fullscreen() -> void:
	fullscreen = not fullscreen
	apply_settings()
	save_settings()
