extends PuzzleBase

@onready var rune_a: Button = $Panel/CipherContainer/RuneA
@onready var rune_b: Button = $Panel/CipherContainer/RuneB
@onready var rune_c: Button = $Panel/CipherContainer/RuneC
@onready var solve_button: Button = $Panel/SolveButton
@onready var status_label: Label = $Panel/StatusLabel
@onready var close_button: Button = $Panel/CloseButton

var rune_states: Array[int] = [0, 0, 0]
var target_states: Array[int] = [2, 1, 3] # Rune indices matching chalkboard equation
var rune_symbols: Array[String] = ["Alpha", "Beta", "Gamma", "Delta"]

func _ready() -> void:
	puzzle_id = "classroom_cipher"
	puzzle_title = "The Schoolhouse Chalkboard Cipher"
	
	rune_a.pressed.connect(func(): _cycle_rune(0, rune_a))
	rune_b.pressed.connect(func(): _cycle_rune(1, rune_b))
	rune_c.pressed.connect(func(): _cycle_rune(2, rune_c))
	
	solve_button.pressed.connect(_on_solve_pressed)
	close_button.pressed.connect(close_puzzle)
	
	_update_rune_labels()

func _cycle_rune(idx: int, btn: Button) -> void:
	rune_states[idx] = (rune_states[idx] + 1) % rune_symbols.size()
	btn.text = rune_symbols[rune_states[idx]]
	status_label.text = "Selecting chalkboard rune..."

func _update_rune_labels() -> void:
	rune_a.text = rune_symbols[rune_states[0]]
	rune_b.text = rune_symbols[rune_states[1]]
	rune_c.text = rune_symbols[rune_states[2]]

func _on_solve_pressed() -> void:
	if rune_states[0] == target_states[0] and rune_states[1] == target_states[1] and rune_states[2] == target_states[2]:
		status_label.text = "EQUATION SOLVED! Emotion 'ANGER' resonates within the device."
		solve_button.disabled = true
		await get_tree().create_timer(1.5).timeout
		solve_puzzle()
	else:
		status_label.text = "The chalkboard sequence remains unresolved."
