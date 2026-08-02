extends Area2D
class_name LocationHotspot

signal hotspot_clicked(location_id: String, target_pos: Vector2)

@export var location_id: String = "CHILD_HOUSE"
@export var location_name: String = "Child's House"
@export_multiline var hover_description: String = "A small, quiet cottage covered in deep snow."

@onready var color_rect: ColorRect = $ColorRect
@onready var label: Label = $Label

var is_hovered: bool = false
var default_color: Color = Color(0.3, 0.6, 0.8, 0.75)

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	input_event.connect(_on_input_event)
	
	if color_rect:
		default_color = color_rect.color
		
	GameManager.chapter_changed.connect(func(_chap): _update_visuals())
	_update_visuals()

func _update_visuals() -> void:
	var is_unlocked = GameManager.is_location_unlocked(location_id)
	if label:
		if is_unlocked:
			label.text = location_name
		else:
			label.text = location_name + "\n[LOCKED]"
			
	if color_rect:
		if is_unlocked:
			color_rect.color = default_color
		else:
			color_rect.color = Color(0.2, 0.2, 0.2, 0.4)

func _on_mouse_entered() -> void:
	is_hovered = true
	if color_rect and GameManager.is_location_unlocked(location_id):
		color_rect.color = Color(1.0, 0.9, 0.5, 0.9)

func _on_mouse_exited() -> void:
	is_hovered = false
	_update_visuals()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if GameManager.is_location_unlocked(location_id):
			print("[Hotspot Clicked] ", location_name)
			hotspot_clicked.emit(location_id, global_position)
		else:
			print("[Hotspot Locked] ", location_name)
