extends Node

signal puzzle_started(puzzle_id: String)
signal puzzle_solved(puzzle_id: String)

var active_puzzle: String = ""

func _ready() -> void:
	print("[BELL BOUND] PuzzleManager initialized.")

func start_puzzle(puzzle_id: String) -> void:
	active_puzzle = puzzle_id
	puzzle_started.emit(puzzle_id)

func solve_puzzle(puzzle_id: String) -> void:
	active_puzzle = ""
	puzzle_solved.emit(puzzle_id)
	GameManager.complete_puzzle(puzzle_id)
