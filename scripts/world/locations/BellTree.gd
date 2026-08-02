extends CanvasLayer

@onready var ring_bell_button: Button = $UI/RingBellButton
@onready var left_arrow_btn: Button = $UI/LeftArrowBtn
@onready var right_arrow_btn: Button = $UI/RightArrowBtn
@onready var dialogue_ui: CanvasLayer = $DialogueUI

func _ready() -> void:
	print("[BELL BOUND] BellTree loaded.")
	ring_bell_button.pressed.connect(_on_ring_bell_pressed)
	left_arrow_btn.pressed.connect(_on_left_arrow_pressed)
	right_arrow_btn.pressed.connect(_on_right_arrow_pressed)

func _on_ring_bell_pressed() -> void:
	var active_emotion = EmotionManager.active_emotion
	if active_emotion == "NONE":
		if dialogue_ui and dialogue_ui.has_method("start_dialogue"):
			dialogue_ui.start_dialogue(
				"The Ancient Bell Tree",
				"Select an emotional frequency on the Resonance Device below first, then press [F] or pull the rope!"
			)
		return
		
	if dialogue_ui and dialogue_ui.has_method("start_dialogue"):
		dialogue_ui.start_dialogue(
			"The Ancient Bell Tree",
			"You project [" + active_emotion + "] into the Great Resonance Bell and pull the rope! A wave of " + active_emotion + " echoes across the frozen peaks, unlocking the Underground Laboratory!"
		)
	GameManager.advance_chapter(6)
	GameManager.unlock_location("FROZEN_LABORATORY")
	await get_tree().create_timer(3.0).timeout
	if SceneTransitionManager:
		SceneTransitionManager.fade_to_location("FROZEN_LABORATORY")
	else:
		GameManager.change_location("FROZEN_LABORATORY")

func _on_left_arrow_pressed() -> void:
	if SceneTransitionManager:
		SceneTransitionManager.fade_to_location("ENGINEER_WORKSHOP")
	else:
		GameManager.change_location("ENGINEER_WORKSHOP")

func _on_right_arrow_pressed() -> void:
	if SceneTransitionManager:
		SceneTransitionManager.fade_to_location("FROZEN_LABORATORY")
	else:
		GameManager.change_location("FROZEN_LABORATORY")
