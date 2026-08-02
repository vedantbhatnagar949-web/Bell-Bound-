extends PuzzleBase

@onready var piece_a: Button = $Panel/PhotoContainer/PieceA
@onready var piece_b: Button = $Panel/PhotoContainer/PieceB
@onready var piece_c: Button = $Panel/PhotoContainer/PieceC
@onready var assemble_button: Button = $Panel/AssembleButton
@onready var status_label: Label = $Panel/StatusLabel
@onready var close_button: Button = $Panel/CloseButton

var piece_rotations: Array[int] = [0, 0, 0]
var target_rotations: Array[int] = [0, 180, 0]

func _ready() -> void:
	puzzle_id = "photograph_puzzle"
	puzzle_title = "The Old Man's Memory Photograph"
	
	piece_a.pressed.connect(func(): _rotate_piece(0, piece_a))
	piece_b.pressed.connect(func(): _rotate_piece(1, piece_b))
	piece_c.pressed.connect(func(): _rotate_piece(2, piece_c))
	
	assemble_button.pressed.connect(_on_assemble_pressed)
	close_button.pressed.connect(close_puzzle)

func _rotate_piece(idx: int, btn: Button) -> void:
	piece_rotations[idx] = (piece_rotations[idx] + 90) % 360
	btn.rotation_degrees = piece_rotations[idx]
	status_label.text = "Rotating photo fragment..."

func _on_assemble_pressed() -> void:
	if piece_rotations[0] == target_rotations[0] and piece_rotations[1] == target_rotations[1] and piece_rotations[2] == target_rotations[2]:
		status_label.text = "MEMORY RESTORED! Emotion 'ACCEPTANCE' resonates within the device."
		assemble_button.disabled = true
		await get_tree().create_timer(1.5).timeout
		solve_puzzle()
	else:
		status_label.text = "The torn edges do not align. Rotate the fragments."
