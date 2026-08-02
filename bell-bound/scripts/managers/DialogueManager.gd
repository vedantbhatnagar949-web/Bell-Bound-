extends Node

signal dialogue_started(speaker_name: String, text_content: String)
signal dialogue_ended()
signal choice_requested(choices: Array)

var is_active: bool = false

func _ready() -> void:
	print("[BELL BOUND] DialogueManager initialized.")

func start_dialogue(speaker_name: String, text_content: String, choices: Array = []) -> void:
	is_active = true
	dialogue_started.emit(speaker_name, text_content)
	if not choices.is_empty():
		choice_requested.emit(choices)

func end_dialogue() -> void:
	is_active = false
	dialogue_ended.emit()
