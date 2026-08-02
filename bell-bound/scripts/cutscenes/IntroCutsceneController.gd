extends Control

@onready var line1: Label = $PhilosophicalVBox/Line1
@onready var line2: Label = $PhilosophicalVBox/Line2
@onready var line3: Label = $PhilosophicalVBox/Line3
@onready var video_player: VideoStreamPlayer = get_node_or_null("VideoStreamPlayer")
@onready var blizzard_panel: Panel = $BlizzardCutscenePanel
@onready var skip_button: Button = $SkipButton

var is_skipping: bool = false

func _ready() -> void:
	skip_button.pressed.connect(_on_skip_pressed)
	_run_intro_sequence()

func _run_intro_sequence() -> void:
	# Fade in Line 1
	var tween1 = create_tween()
	tween1.tween_property(line1, "theme_override_colors/font_color:a", 1.0, 1.5)
	await tween1.finished
	if is_skipping: return
	await get_tree().create_timer(1.0).timeout
	if is_skipping: return
	
	# Fade in Line 2
	var tween2 = create_tween()
	tween2.tween_property(line2, "theme_override_colors/font_color:a", 1.0, 1.5)
	await tween2.finished
	if is_skipping: return
	await get_tree().create_timer(1.0).timeout
	if is_skipping: return
	
	# Fade in Line 3
	var tween3 = create_tween()
	tween3.tween_property(line3, "theme_override_colors/font_color:a", 1.0, 1.5)
	await tween3.finished
	if is_skipping: return
	await get_tree().create_timer(1.5).timeout
	if is_skipping: return
	
	# Try Video Playback first
	var played_video = _play_intro_video_if_exists()
	if not played_video:
		blizzard_panel.visible = true
		await get_tree().create_timer(3.5).timeout
		if is_skipping: return
	else:
		if video_player:
			await video_player.finished
			
	_finish_intro()

func _play_intro_video_if_exists() -> bool:
	var possible_paths = [
		"res://videos/walking_into_village.ogv",
		"res://videos/intro_walk.ogv"
	]
	for path in possible_paths:
		if video_player and ResourceLoader.exists(path):
			var stream = load(path) as VideoStream
			if stream:
				video_player.stream = stream
				video_player.visible = true
				video_player.play()
				print("[IntroCutscene] Playing custom intro video: ", path)
				return true
	return false

func _on_skip_pressed() -> void:
	is_skipping = true
	_finish_intro()

func _finish_intro() -> void:
	print("[IntroCutscene] Sequence finished -> Transitioning to Child's Cottage.")
	if SceneTransitionManager:
		SceneTransitionManager.fade_to_location("CHILD_HOUSE")
	else:
		GameManager.change_location("CHILD_HOUSE")
