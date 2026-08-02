extends Control

@onready var narrative_label: Label = $Panel/NarrativeLabel
@onready var action_button: Button = $Panel/ActionButton
@onready var hide_in_bell_btn: Button = get_node_or_null("Panel/HideInBellBtn")
@onready var sacrifice_btn: Button = get_node_or_null("Panel/SacrificeBtn")
@onready var video_player: VideoStreamPlayer = get_node_or_null("Panel/VideoStreamPlayer")
@onready var black_electricity_visual: ColorRect = $Panel/BlackElectricityVisual
@onready var bell_slide_visual: ColorRect = $Panel/BellSlideVisual
@onready var whiteout_overlay: ColorRect = $Panel/WhiteoutOverlay
@onready var credits_panel: Panel = $Panel/CreditsPanel

enum PathAPhase {
	AI_JUDGMENT,
	CREDITS
}

enum PathBPhase {
	VILLAGERS_LOCKUP,
	PICK_LOCK,
	CLIMB_SPIRAL_STAIRS,
	RESONANCE_SURGE,
	CUT_ROPE,
	MOUNTAIN_SLIDE,
	HIDE_IN_BELL_ENDING,
	SACRIFICE_ENDING,
	CREDITS
}

var is_path_a: bool = false
var path_a_phase: PathAPhase = PathAPhase.AI_JUDGMENT
var path_b_phase: PathBPhase = PathBPhase.VILLAGERS_LOCKUP
var slide_timer: float = 0.0

func _ready() -> void:
	is_path_a = GameManager.player_pressed_stop_button
	action_button.pressed.connect(_on_action_pressed)
	if hide_in_bell_btn: hide_in_bell_btn.pressed.connect(_on_hide_in_bell_pressed)
	if sacrifice_btn: sacrifice_btn.pressed.connect(_on_sacrifice_pressed)
	
	if is_path_a:
		print("[FinalClimax] Running PATH A: Player pressed STOP button.")
		_run_path_a()
	else:
		print("[FinalClimax] Running PATH B: Player ignored STOP button.")
		_run_path_b()

func _process(delta: float) -> void:
	if not is_path_a and path_b_phase == PathBPhase.MOUNTAIN_SLIDE:
		slide_timer += delta * 150.0
		bell_slide_visual.position.x += slide_timer * delta
		bell_slide_visual.position.y += slide_timer * delta * 0.8
		bell_slide_visual.scale = bell_slide_visual.scale.lerp(Vector2(2.5, 2.5), delta * 0.5)

func _play_custom_video_if_exists(video_res_path: String) -> bool:
	if video_player and ResourceLoader.exists(video_res_path):
		var stream = load(video_res_path) as VideoStream
		if stream:
			video_player.stream = stream
			video_player.visible = true
			video_player.play()
			print("[VideoCutscene] Playing custom video: ", video_res_path)
			return true
	return false

# PATH A: STOP BUTTON PRESSED (GROQ AI MORAL JUDGMENT)
func _run_path_a() -> void:
	match path_a_phase:
		PathAPhase.AI_JUDGMENT:
			var rng = randf()
			if rng < 0.7:
				narrative_label.text = "PATH A — GROQ AI MORAL JUDGMENT: BANISHMENT (70% Probability)\n\nYou pressed the STOP button. Real emotions flood back into the village!\nRealizing you manipulated their minds with the Resonance Device, the villagers gather with cold eyes and escort you out of the snowy village into exile.\n\n\"Leave our mountain forever.\""
			else:
				narrative_label.text = "PATH A — GROQ AI MORAL JUDGMENT: FORGIVENESS (30% Probability)\n\nYou pressed the STOP button. Real emotions flood back into the village!\nRecognizing your genuine remorse in shutting down the device, Arthur steps forward and places a hand on your shoulder: 'You gave us back our authentic hearts. We forgive you.'"
			action_button.text = "View Credits >"
			
		PathAPhase.CREDITS:
			if video_player: video_player.visible = false
			whiteout_overlay.visible = false
			credits_panel.visible = true
			action_button.text = "Return to Main Menu"

# PATH B: STOP BUTTON IGNORED
func _run_path_b() -> void:
	match path_b_phase:
		PathBPhase.VILLAGERS_LOCKUP:
			narrative_label.text = "Discovering you controlled their authentic feelings with the Resonance Device, the angry villagers escort you into the cold wooden Bell Tower room and slam the heavy iron lock shut from the outside!"
			action_button.text = "Inspect Bell Tower Door Lock >"
			
		PathBPhase.PICK_LOCK:
			narrative_label.text = "You insert a thin resonance wire into the keyhole and carefully align the pins..."
			action_button.text = "Pick Heavy Iron Lock >"
			
		PathBPhase.CLIMB_SPIRAL_STAIRS:
			_play_custom_video_if_exists("res://videos/climbing_stairs.ogv")
			narrative_label.text = "CLICK! The heavy lock pops open!\nYou push open the heavy oak door and sprint up the dark, winding stone spiral staircase to the top of the Bell Tower!"
			action_button.text = "Reach Tower Peak >"
			
		PathBPhase.RESONANCE_SURGE:
			black_electricity_visual.visible = true
			narrative_label.text = "At the top of the tower, Toby's accidental resonance surge is overloading the Great Bell!\nDark electricity crackles through the mountain sky! The whole tower trembles!"
			action_button.text = "Cut Master Holding Rope! >"
			
		PathBPhase.CUT_ROPE:
			narrative_label.text = "With one sharp slice of your knife, the master iron holding rope SNAPS!\nThe massive mountain bell drops onto the snowy slope!"
			action_button.text = "Leap onto Mountain Bell Slide! >"
			
		PathBPhase.MOUNTAIN_SLIDE:
			var played_vid = _play_custom_video_if_exists("res://videos/bell_impact.ogv")
			if not played_vid:
				bell_slide_visual.visible = true
			narrative_label.text = "You leap onto the giant Bell as it slides down the snowy mountain at accelerating speed!\nTrees shatter! Snow explodes!\nThe bell reaches the bottom of the slope — MAKE YOUR CHOICE!"
			action_button.visible = false
			if hide_in_bell_btn: hide_in_bell_btn.visible = true
			if sacrifice_btn: sacrifice_btn.visible = true
			
		PathBPhase.HIDE_IN_BELL_ENDING:
			if hide_in_bell_btn: hide_in_bell_btn.visible = false
			if sacrifice_btn: sacrifice_btn.visible = false
			action_button.visible = true
			if video_player: video_player.visible = false
			narrative_label.text = "CHOICE 1: HIDE INSIDE THE BELL\nYou pull yourself deep inside the heavy iron shell of the Bell as it crashes into the frozen valley!\nYou survive unharmed, but the uncontrolled resonance surge explodes outward—destroying the village and leaving only silence behind."
			action_button.text = "View Credits >"

		PathBPhase.SACRIFICE_ENDING:
			if hide_in_bell_btn: hide_in_bell_btn.visible = false
			if sacrifice_btn: sacrifice_btn.visible = false
			action_button.visible = true
			if video_player: video_player.visible = false
			whiteout_overlay.visible = true
			narrative_label.text = "CHOICE 2: SACRIFICE TO SAVE THE VILLAGE\nYou leap out from the bell at the last moment to anchor it into the mountain ice!\nThe overused Resonance Device shatters into colorful glowing dust, dissolving all mental control!\nToby laughs. Arthur smiles. Evelyn teaches freely. Victor smiles at his engine.\n\"They deserved their own hearts.\""
			action_button.text = "View Credits >"
			
		PathBPhase.CREDITS:
			if video_player: video_player.visible = false
			whiteout_overlay.visible = false
			credits_panel.visible = true
			action_button.text = "Return to Main Menu"

func _on_hide_in_bell_pressed() -> void:
	print("[Climax] Player chose: HIDE INSIDE BELL.")
	GameManager.player_chose_sacrifice = false
	path_b_phase = PathBPhase.HIDE_IN_BELL_ENDING
	_run_path_b()

func _on_sacrifice_pressed() -> void:
	print("[Climax] Player chose: SACRIFICE TO SAVE VILLAGE.")
	GameManager.player_chose_sacrifice = true
	path_b_phase = PathBPhase.SACRIFICE_ENDING
	_run_path_b()

func _on_action_pressed() -> void:
	if is_path_a:
		match path_a_phase:
			PathAPhase.AI_JUDGMENT:
				path_a_phase = PathAPhase.CREDITS
				_run_path_a()
			PathAPhase.CREDITS:
				GameManager.change_location("MAIN_MENU")
	else:
		match path_b_phase:
			PathBPhase.VILLAGERS_LOCKUP:
				path_b_phase = PathBPhase.PICK_LOCK
			PathBPhase.PICK_LOCK:
				path_b_phase = PathBPhase.CLIMB_SPIRAL_STAIRS
			PathBPhase.CLIMB_SPIRAL_STAIRS:
				path_b_phase = PathBPhase.RESONANCE_SURGE
			PathBPhase.RESONANCE_SURGE:
				path_b_phase = PathBPhase.CUT_ROPE
			PathBPhase.CUT_ROPE:
				path_b_phase = PathBPhase.MOUNTAIN_SLIDE
			PathBPhase.HIDE_IN_BELL_ENDING, PathBPhase.SACRIFICE_ENDING:
				path_b_phase = PathBPhase.CREDITS
			PathBPhase.CREDITS:
				GameManager.change_location("MAIN_MENU")
				return
		_run_path_b()
