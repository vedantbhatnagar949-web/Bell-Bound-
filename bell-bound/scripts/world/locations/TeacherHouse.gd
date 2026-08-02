extends CanvasLayer

@onready var dialogue_ui: CanvasLayer = $DialogueUI
@onready var evelyn_btn: TextureButton = $EvelynClickable
@onready var left_arrow_btn: Button = $LeftArrowBtn
@onready var right_arrow_btn: Button = $RightArrowBtn
@onready var puzzle_container: Control = $PuzzleContainer

func _ready() -> void:
	print("[BELL BOUND] TeacherHouse loaded — The Schoolhouse")
	evelyn_btn.pressed.connect(_on_evelyn_tapped)
	left_arrow_btn.pressed.connect(_on_left_arrow_pressed)
	right_arrow_btn.pressed.connect(_on_right_arrow_pressed)
	if dialogue_ui and dialogue_ui.has_signal("dialogue_finished"):
		dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)

func _on_evelyn_tapped() -> void:
	GameManager.mark_npc_talked("Evelyn")
	var memories = GameManager.npc_data["Evelyn"]["memories"]
	var line = memories[randi() % memories.size()]
	dialogue_ui.start_dialogue("Evelyn", line, GameManager.npc_data["Evelyn"]["current_emotion"])

func _on_dialogue_finished() -> void:
	pass

func _on_left_arrow_pressed() -> void:
	if SceneTransitionManager:
		SceneTransitionManager.change_scene_with_fade("res://scenes/oldman_house/OldManHouse.tscn")
	else:
		GameManager.change_location("OLD_MAN_HOUSE")

func _on_right_arrow_pressed() -> void:
	if SceneTransitionManager:
		SceneTransitionManager.change_scene_with_fade("res://scenes/engineer/EngineerWorkshop.tscn")
	else:
		GameManager.change_location("ENGINEER_WORKSHOP")
