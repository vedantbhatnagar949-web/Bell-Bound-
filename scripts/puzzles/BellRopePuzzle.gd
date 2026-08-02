extends PuzzleBase

@onready var lever_a: Button = $Panel/LeverContainer/LeverA
@onready var lever_b: Button = $Panel/LeverContainer/LeverB
@onready var lever_c: Button = $Panel/LeverContainer/LeverC
@onready var pull_rope_button: Button = $Panel/PullRopeButton
@onready var status_label: Label = $Panel/StatusLabel
@onready var close_button: Button = $Panel/CloseButton

var lever_positions: Array[bool] = [false, false, false]

func _ready() -> void:
	puzzle_id = "bell_rope_mechanism"
	puzzle_title = "The Bell Tree Rope Counterweight"
	
	lever_a.pressed.connect(func(): _toggle_lever(0, lever_a))
	lever_b.pressed.connect(func(): _toggle_lever(1, lever_b))
	lever_c.pressed.connect(func(): _toggle_lever(2, lever_c))
	
	pull_rope_button.pressed.connect(_on_pull_rope_pressed)
	close_button.pressed.connect(close_puzzle)

func _toggle_lever(idx: int, btn: Button) -> void:
	lever_positions[idx] = not lever_positions[idx]
	btn.text = "Lever " + str(idx+1) + "\n" + ("UP" if lever_positions[idx] else "DOWN")
	status_label.text = "Engaging counterweight pulley..."

func _on_pull_rope_pressed() -> void:
	if lever_positions[0] and not lever_positions[1] and lever_positions[2]:
		status_label.text = "THE GIANT BELL RINGS! A DEEP RESONANT ECHO FILLS THE MOUNTAIN VALLEY!"
		pull_rope_button.disabled = true
		await get_tree().create_timer(2.0).timeout
		solve_puzzle()
	else:
		status_label.text = "The ancient rope tension is uneven. Adjust counterweight levers."
