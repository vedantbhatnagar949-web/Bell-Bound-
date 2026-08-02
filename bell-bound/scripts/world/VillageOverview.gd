extends CanvasLayer

@onready var child_house_btn: Button = $LocationsContainer/ChildHouseBtn
@onready var oldman_house_btn: Button = $LocationsContainer/OldManHouseBtn
@onready var teacher_house_btn: Button = $LocationsContainer/TeacherHouseBtn
@onready var engineer_workshop_btn: Button = $LocationsContainer/EngineerWorkshopBtn
@onready var bell_tree_btn: Button = $LocationsContainer/BellTreeBtn
@onready var frozen_lab_btn: Button = $LocationsContainer/FrozenLabBtn
@onready var final_climax_btn: Button = $LocationsContainer/FinalClimaxBtn

func _ready() -> void:
	print("[BELL BOUND] VillageOverview map ready.")
	
	child_house_btn.pressed.connect(func(): _on_location_selected("CHILD_HOUSE"))
	oldman_house_btn.pressed.connect(func(): _on_location_selected("OLD_MAN_HOUSE"))
	teacher_house_btn.pressed.connect(func(): _on_location_selected("TEACHER_HOUSE"))
	engineer_workshop_btn.pressed.connect(func(): _on_location_selected("ENGINEER_WORKSHOP"))
	bell_tree_btn.pressed.connect(func(): _on_location_selected("BELL_TREE"))
	frozen_lab_btn.pressed.connect(func(): _on_location_selected("FROZEN_LABORATORY"))
	final_climax_btn.pressed.connect(func(): _on_location_selected("FINAL_CLIMAX"))
	
	GameManager.chapter_changed.connect(func(_chap): _update_buttons())
	_update_buttons()

func _update_buttons() -> void:
	_set_button_state(child_house_btn, "CHILD_HOUSE", "1. Child's Cottage (Hope)")
	_set_button_state(oldman_house_btn, "OLD_MAN_HOUSE", "2. Old Man's House (Acceptance)")
	_set_button_state(teacher_house_btn, "TEACHER_HOUSE", "3. Schoolhouse (Anger)")
	_set_button_state(engineer_workshop_btn, "ENGINEER_WORKSHOP", "4. Engineer's Workshop (Fear)")
	_set_button_state(bell_tree_btn, "BELL_TREE", "5. The Bell Tree")
	_set_button_state(frozen_lab_btn, "FROZEN_LABORATORY", "6. Frozen Laboratory")
	_set_button_state(final_climax_btn, "FINAL_CLIMAX", "7. Final Climax")

func _set_button_state(btn: Button, loc_id: String, title: String) -> void:
	var is_unlocked = GameManager.is_location_unlocked(loc_id)
	if is_unlocked:
		btn.text = title
		btn.disabled = false
	else:
		btn.text = title + " [LOCKED]"
		btn.disabled = true

func _on_location_selected(loc_id: String) -> void:
	if GameManager.is_location_unlocked(loc_id):
		print("[VillageOverview] Transitioning to location: ", loc_id)
		GameManager.change_location(loc_id)
