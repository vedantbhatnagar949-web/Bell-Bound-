extends Control

@onready var start_game_btn: Button = $ButtonVBox/StartGameBtn
@onready var settings_btn: Button = $ButtonVBox/SettingsBtn
@onready var quit_btn: Button = $ButtonVBox/QuitBtn

func _ready() -> void:
	start_game_btn.pressed.connect(_on_start_game_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)

func _on_start_game_pressed() -> void:
	print("[MainMenu] Starting game sequence -> IntroCutscene.")
	get_tree().change_scene_to_file("res://scenes/cutscenes/IntroCutscene.tscn")

func _on_settings_pressed() -> void:
	print("[MainMenu] Settings clicked.")

func _on_quit_pressed() -> void:
	get_tree().quit()
