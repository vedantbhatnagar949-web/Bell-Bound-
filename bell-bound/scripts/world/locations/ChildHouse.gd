extends CanvasLayer

@onready var dialogue_ui: CanvasLayer = $DialogueUI
@onready var toby_btn: TextureButton = $TobyClickable
@onready var right_arrow_btn: Button = $RightArrowBtn
@onready var puzzle_container: Control = $PuzzleContainer

func _ready() -> void:
	print("[BELL BOUND] ChildHouse loaded — Toby's Cottage")
	toby_btn.pressed.connect(_on_toby_tapped)
	right_arrow_btn.pressed.connect(_on_right_arrow_pressed)
	if dialogue_ui and dialogue_ui.has_signal("dialogue_finished"):
		dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)

func _on_toby_tapped() -> void:
	GameManager.mark_npc_talked("Toby")
	var memories = GameManager.npc_data["Toby"]["memories"]
	var line = memories[randi() % memories.size()]
	dialogue_ui.start_dialogue("Toby", line, GameManager.npc_data["Toby"]["current_emotion"])

func _on_dialogue_finished() -> void:
	pass

func _on_right_arrow_pressed() -> void:
	if SceneTransitionManager:
		SceneTransitionManager.change_scene_with_fade("res://scenes/oldman_house/OldManHouse.tscn")
	else:
		GameManager.change_location("OLD_MAN_HOUSE")
