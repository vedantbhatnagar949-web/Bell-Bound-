extends CanvasLayer

@onready var read_journal_button: Button = get_node_or_null("UI/ReadJournalButton")
@onready var press_stop_btn: Button = get_node_or_null("UI/PressStopBtn")
@onready var refuse_stop_btn: Button = get_node_or_null("UI/RefuseStopBtn")
@onready var left_arrow_btn: Button = get_node_or_null("UI/LeftArrowBtn")
@onready var dialogue_ui: CanvasLayer = $DialogueUI

func _ready() -> void:
	print("[BELL BOUND] FrozenLaboratory loaded.")
	if read_journal_button: read_journal_button.pressed.connect(_on_read_journal_pressed)
	if press_stop_btn: press_stop_btn.pressed.connect(_on_press_stop_pressed)
	if refuse_stop_btn: refuse_stop_btn.pressed.connect(_on_refuse_stop_pressed)
	if left_arrow_btn: left_arrow_btn.pressed.connect(_on_left_arrow_pressed)
	
	GameManager.advance_chapter(6) # Unlocks hidden STOP button on bottom-right ResonanceHUD

func _on_read_journal_pressed() -> void:
	if dialogue_ui and dialogue_ui.has_method("start_dialogue"):
		dialogue_ui.start_dialogue(
			"Victor & Ancient Blueprints",
			"THE MORAL TRUTH REVEALED: Victor uncovers the ancient blueprints! The Resonance Device was built to force emotional projections into human minds! Choose your action below:"
		)
	if press_stop_btn: press_stop_btn.visible = true
	if refuse_stop_btn: refuse_stop_btn.visible = true

func _on_press_stop_pressed() -> void:
	print("[FrozenLab] Player explicitly chose: PRESS STOP BUTTON.")
	GameManager.player_pressed_stop_button = true
	if SceneTransitionManager:
		SceneTransitionManager.fade_to_location("FINAL_CLIMAX")
	else:
		GameManager.change_location("FINAL_CLIMAX")

func _on_refuse_stop_pressed() -> void:
	print("[FrozenLab] Player explicitly chose: REFUSE TO PRESS STOP BUTTON.")
	GameManager.player_pressed_stop_button = false
	if SceneTransitionManager:
		SceneTransitionManager.fade_to_location("BELL_TOWER_ROOM")
	else:
		GameManager.change_location("BELL_TOWER_ROOM")

func _on_left_arrow_pressed() -> void:
	if SceneTransitionManager:
		SceneTransitionManager.fade_to_location("BELL_TREE")
	else:
		GameManager.change_location("BELL_TREE")
