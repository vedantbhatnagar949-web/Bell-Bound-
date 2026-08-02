extends Control
class_name PuzzleBase

signal puzzle_solved(puzzle_id: String)
signal puzzle_closed

@export var puzzle_id: String = "base_puzzle"
@export var puzzle_title: String = "Handcrafted Puzzle"

var is_solved: bool = false

func _ready() -> void:
	print("[PuzzleBase] Initialized puzzle: ", puzzle_id)

func solve_puzzle() -> void:
	if not is_solved:
		is_solved = true
		print("[PuzzleBase] Solved: ", puzzle_id)
		puzzle_solved.emit(puzzle_id)
		GameManager.complete_puzzle(puzzle_id)
		close_puzzle()

func close_puzzle() -> void:
	puzzle_closed.emit()
	queue_free()
