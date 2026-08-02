extends CanvasLayer

@onready var talk_button: Button = get_node_or_null("UI/TalkNPCButton")
@onready var project_emotion_btn: Button = get_node_or_null("UI/ProjectEmotionBtn")
@onready var interact_valve_btn: Button = get_node_or_null("UI/InteractValveBtn")
@onready var left_arrow_btn: Button = get_node_or_null("UI/LeftArrowBtn")
@onready var right_arrow_btn: Button = get_node_or_null("UI/RightArrowBtn")

@onready var dialogue_ui: CanvasLayer = $DialogueUI
@onready var puzzle_container: Control = $PuzzleContainer

@onready var victor_visual: Control = get_node_or_null("VictorNPCVisual")
@onready var victor_state_label: Label = get_node_or_null("VictorNPCVisual/StateLabel")
@onready var object_state_label: Label = get_node_or_null("ValveVisual/ObjectStateLabel")

func _ready() -> void:
	print("[BELL BOUND] EngineerWorkshop loaded.")
	if talk_button: talk_button.pressed.connect(_on_talk_pressed)
	if project_emotion_btn: project_emotion_btn.pressed.connect(_on_project_emotion_pressed)
	if interact_valve_btn: interact_valve_btn.pressed.connect(_on_interact_valve_pressed)
	if left_arrow_btn: left_arrow_btn.pressed.connect(_on_left_arrow_pressed)
	if right_arrow_btn: right_arrow_btn.pressed.connect(_on_right_arrow_pressed)
	
	if dialogue_ui and dialogue_ui.has_signal("dialogue_finished"):
		dialogue_ui.dialogue_finished.connect(_on_dialogue_received)
		
	_update_npc_presence()

func _update_npc_presence() -> void:
	var victor_here = GameManager.is_npc_present_at("Victor", "ENGINEER_WORKSHOP")
	if victor_visual: victor_visual.visible = victor_here
	if talk_button: talk_button.visible = victor_here
	if victor_state_label:
		victor_state_label.text = "[" + GameManager.get_relationship_status("Victor") + "]"

func _on_talk_pressed() -> void:
	GameManager.mark_npc_talked("Victor")
	var memories = GameManager.npc_data["Victor"]["memories"]
	var line = memories[randi() % memories.size()]
	dialogue_ui.start_dialogue("Victor", line, GameManager.npc_data["Victor"]["current_emotion"])

func _on_dialogue_received() -> void:
	_update_npc_presence()

func _on_project_emotion_pressed() -> void:
	var active = EmotionManager.active_emotion
	if active == "NONE":
		dialogue_ui.start_dialogue("System", "Select an emotion frequency on the Resonance HUD first!")
	else:
		GameManager.record_emotion_projection("Victor", active)
		dialogue_ui.start_dialogue("Victor", "*Resonates with " + active + " frequency*", active)
		_update_npc_presence()

func _on_interact_valve_pressed() -> void:
	if not GameManager.has_talked_to_npc["Victor"]:
		dialogue_ui.start_dialogue("Victor", "You must talk to Victor first before adjusting the steam pressure valve!")
		return
		
	print("[EngineerWorkshop] Opening MechanicalPuzzle...")
	var puzzle_scene = load("res://scenes/puzzles/MechanicalPuzzle.tscn").instantiate()
	puzzle_container.add_child(puzzle_scene)
	if puzzle_scene.has_signal("puzzle_solved"):
		puzzle_scene.puzzle_solved.connect(func():
			object_state_label.text = "[Status: CALIBRATED]"
			dialogue_ui.start_dialogue("Victor", "The pressure is equalized! The path to the Bell Tree and Lab is clear!", "HOPE")
		)

func _on_left_arrow_pressed() -> void:
	if SceneTransitionManager:
		SceneTransitionManager.change_scene_with_fade("res://scenes/teacher_house/TeacherHouse.tscn")
	else:
		GameManager.change_location("TEACHER_HOUSE")

func _on_right_arrow_pressed() -> void:
	if GameManager.is_location_unlocked("FROZEN_LABORATORY"):
		if SceneTransitionManager:
			SceneTransitionManager.change_scene_with_fade("res://scenes/world/locations/FrozenLaboratory.tscn")
		else:
			GameManager.change_location("FROZEN_LABORATORY")
	else:
		dialogue_ui.start_dialogue("System", "The path forward to the Frozen Laboratory is locked! Complete ACT 1 tasks first.")
