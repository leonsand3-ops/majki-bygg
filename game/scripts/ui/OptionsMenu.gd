extends Control

@onready var fullscreen_check: CheckButton = $VBoxContainer/FullscreenCheck
@onready var master_slider: HSlider = $VBoxContainer/MasterVolume/Slider
@onready var music_slider: HSlider = $VBoxContainer/MusicVolume/Slider
@onready var sfx_slider: HSlider = $VBoxContainer/SFXVolume/Slider
@onready var btn_back: Button = $VBoxContainer/BtnBack


func _ready() -> void:
	fullscreen_check.button_pressed = SettingsManager.fullscreen
	master_slider.value = SettingsManager.volume_master
	music_slider.value = SettingsManager.volume_music
	sfx_slider.value = SettingsManager.volume_sfx

	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	btn_back.pressed.connect(_on_back)


func _on_fullscreen_toggled(pressed: bool) -> void:
	SettingsManager.fullscreen = pressed
	SettingsManager.apply_settings()
	SettingsManager.save_settings()


func _on_master_changed(value: float) -> void:
	SettingsManager.volume_master = value
	AudioManager.set_bus_volume("Master", value)
	SettingsManager.save_settings()


func _on_music_changed(value: float) -> void:
	SettingsManager.volume_music = value
	AudioManager.set_bus_volume("Music", value)
	SettingsManager.save_settings()


func _on_sfx_changed(value: float) -> void:
	SettingsManager.volume_sfx = value
	AudioManager.set_bus_volume("SFX", value)
	SettingsManager.save_settings()


func _on_back() -> void:
	AudioManager.play_sfx("button_click")
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
