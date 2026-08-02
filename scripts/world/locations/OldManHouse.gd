extends CanvasLayer

@onready var dialogue_ui: CanvasLayer = $DialogueUI
@onready var arthur_btn: TextureButton = $ArthurClickable
@onready var left_arrow_btn: Button = $LeftArrowBtn
@onready var right_arrow_btn: Button = $RightArrowBtn
@onready var puzzle_container: Control = $PuzzleContainer

func _ready() -> void:
	print("[BELL BOUND] OldManHouse loaded — Arthur's Cottage")
	arthur_btn.pressed.connect(_on_arthur_tapped)
	left_arrow_btn.pressed.connect(_on_left_arrow_pressed)
	right_arrow_btn.pressed.connect(_on_right_arrow_pressed)
	if dialogue_ui and dialogue_ui.has_signal("dialogue_finished"):
		dialogue_ui.dialogue_finished.connect(_on_dialogue_finished)

func _on_arthur_tapped() -> void:
	GameManager.mark_npc_talked("Arthur")
	var memories = GameManager.npc_data["Arthur"]["memories"]
	var line = memories[randi() % memories.size()]
	dialogue_ui.start_dialogue("Arthur", line, GameManager.npc_data["Arthur"]["current_emotion"])

func _on_dialogue_finished() -> void:
	pass

func _on_left_arrow_pressed() -> void:
	if SceneTransitionManager:
		SceneTransitionManager.change_scene_with_fade("res://scenes/child_house/ChildHouse.tscn")
	else:
		GameManager.change_location("CHILD_HOUSE")

func _on_right_arrow_pressed() -> void:
	if SceneTransitionManager:
		SceneTransitionManager.change_scene_with_fade("res://scenes/teacher_house/TeacherHouse.tscn")
	else:
		GameManager.change_location("TEACHER_HOUSE")
