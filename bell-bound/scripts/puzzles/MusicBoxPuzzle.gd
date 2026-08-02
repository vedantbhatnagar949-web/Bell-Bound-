extends PuzzleBase

@onready var gear_a: Button = $Panel/GearContainer/GearA
@onready var gear_b: Button = $Panel/GearContainer/GearB
@onready var gear_c: Button = $Panel/GearContainer/GearC
@onready var wind_key_button: Button = $Panel/WindKeyButton
@onready var status_label: Label = $Panel/StatusLabel
@onready var close_button: Button = $Panel/CloseButton

var gear_rotations: Array[int] = [0, 0, 0] # 0, 90, 180, 270 degrees
var target_rotations: Array[int] = [180, 90, 270]

func _ready() -> void:
	puzzle_id = "music_box_repair"
	puzzle_title = "The Child's Music Box"
	
	gear_a.pressed.connect(func(): _rotate_gear(0, gear_a))
	gear_b.pressed.connect(func(): _rotate_gear(1, gear_b))
	gear_c.pressed.connect(func(): _rotate_gear(2, gear_c))
	
	wind_key_button.pressed.connect(_on_wind_key_pressed)
	close_button.pressed.connect(close_puzzle)
	
	_update_gear_visuals()

func _rotate_gear(index: int, button: Button) -> void:
	gear_rotations[index] = (gear_rotations[index] + 90) % 360
	button.rotation_degrees = gear_rotations[index]
	status_label.text = "Adjusting gear alignments..."

func _on_wind_key_pressed() -> void:
	if gear_rotations[0] == target_rotations[0] and gear_rotations[1] == target_rotations[1] and gear_rotations[2] == target_rotations[2]:
		status_label.text = "HARMONY RESTORED! Emotion 'HOPE' resonates within the device."
		wind_key_button.disabled = true
		solve_puzzle()
	else:
		status_label.text = "The music box sputters... Gears are misaligned!"

func _update_gear_visuals() -> void:
	gear_a.rotation_degrees = gear_rotations[0]
	gear_b.rotation_degrees = gear_rotations[1]
	gear_c.rotation_degrees = gear_rotations[2]
