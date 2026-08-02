extends CanvasLayer

@onready var pick_lock_btn: Button = get_node_or_null("UI/PickLockBtn")
@onready var climb_stairs_btn: Button = get_node_or_null("UI/ClimbStairsBtn")
@onready var dialogue_ui: CanvasLayer = $DialogueUI
@onready var door_status_label: Label = get_node_or_null("LockedDoorVisual/DoorStatusLabel")

var is_unlocked: bool = false

func _ready() -> void:
	print("[BELL BOUND] BellTowerRoom loaded.")
	if pick_lock_btn: pick_lock_btn.pressed.connect(_on_pick_lock_pressed)
	if climb_stairs_btn: climb_stairs_btn.pressed.connect(_on_climb_stairs_pressed)
	
	if dialogue_ui and dialogue_ui.has_method("start_dialogue"):
		dialogue_ui.start_dialogue(
			"Inside the Bell Tower Room",
			"The angry villagers locked you inside the cold Bell Tower room! Insert your resonance pin into the iron lock to escape!"
		)

func _on_pick_lock_pressed() -> void:
	is_unlocked = true
	if door_status_label:
		door_status_label.text = "[UNLOCKED - DOOR OPEN]"
	if pick_lock_btn:
		pick_lock_btn.visible = false
	if climb_stairs_btn:
		climb_stairs_btn.visible = true
		
	if dialogue_ui and dialogue_ui.has_method("start_dialogue"):
		dialogue_ui.start_dialogue(
			"Inside the Bell Tower Room",
			"CLICK! The heavy iron lock pops open! You push open the heavy oak door leading to the winding stone spiral stairs!"
		)

func _on_climb_stairs_pressed() -> void:
	if SceneTransitionManager:
		SceneTransitionManager.fade_to_location("FINAL_CLIMAX")
	else:
		GameManager.change_location("FINAL_CLIMAX")
