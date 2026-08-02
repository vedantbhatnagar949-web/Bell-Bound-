extends CanvasLayer

signal transition_finished

@onready var color_rect: ColorRect = ColorRect.new()

var is_transitioning: bool = false

func _ready() -> void:
	layer = 200 # Always on top of everything
	color_rect.anchors_preset = Control.PRESET_FULL_RECT
	color_rect.color = Color(0, 0, 0, 0)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(color_rect)
	print("[BELL BOUND] SceneTransitionManager ready with smooth screen fade engine.")

func fade_to_location(target_location_id: String) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Fade Out to Black (0.4 seconds)
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	
	# Change Location Scene
	GameManager.change_location(target_location_id)
	await get_tree().create_timer(0.1).timeout
	
	# Fade In from Black (0.4 seconds)
	var tween_in = create_tween()
	tween_in.tween_property(color_rect, "color:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween_in.finished
	
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false
	transition_finished.emit()

func change_scene_with_fade(scene_path: String) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Fade Out to Black
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	
	# Change Scene
	get_tree().change_scene_to_file(scene_path)
	await get_tree().create_timer(0.1).timeout
	
	# Fade In from Black
	var tween_in = create_tween()
	tween_in.tween_property(color_rect, "color:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween_in.finished
	
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false
	transition_finished.emit()
