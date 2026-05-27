extends Control

@onready var main_buttons: VBoxContainer = $CenterContainer/MainButtons
@onready var settings_menu: VBoxContainer = $CenterContainer/SettingsMenu
@onready var credits_menu: VBoxContainer = $CenterContainer/CreditsMenu
@onready var fullscreen: CheckBox = $CenterContainer/SettingsMenu/Fullscreen
@onready var volumen: HSlider = $CenterContainer/SettingsMenu/Volumen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fullscreen.button_pressed = true if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN else false
	volumen.value = AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("Master"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/mundo.tscn")


func _on_settings_pressed() -> void:
	main_buttons.visible = false
	settings_menu.visible = true


func _on_credits_pressed() -> void:
	main_buttons.visible = false
	credits_menu.visible = true


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	main_buttons.visible = true
	settings_menu.visible = false
	credits_menu.visible = false


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)


func _on_volumen_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)
