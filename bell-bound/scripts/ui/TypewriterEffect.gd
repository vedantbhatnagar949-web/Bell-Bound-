extends Node

signal typewriter_finished

var target_label: Label
var full_text: String = ""
var current_char_index: int = 0
var char_speed: float = 0.025
var is_typing: bool = false
var timer: float = 0.0

func setup(label: Label) -> void:
	target_label = label

func start_typing(text: String, speed: float = 0.025) -> void:
	full_text = text
	char_speed = speed
	current_char_index = 0
	is_typing = true
	timer = 0.0
	if target_label:
		target_label.text = ""

func process_typewriter(delta: float) -> void:
	if not is_typing or not target_label:
		return
		
	timer += delta
	if timer >= char_speed:
		timer = 0.0
		current_char_index += 1
		if current_char_index <= full_text.length():
			target_label.text = full_text.substr(0, current_char_index)
		else:
			is_typing = false
			typewriter_finished.emit()

func skip() -> void:
	if is_typing and target_label:
		is_typing = false
		target_label.text = full_text
		typewriter_finished.emit()
