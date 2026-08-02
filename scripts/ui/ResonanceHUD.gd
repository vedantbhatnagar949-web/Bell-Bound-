extends CanvasLayer

signal cast_requested

@onready var status_label: Label = $BottomRightContainer/DevicePanel/MainVBox/StatusLabel
@onready var hope_btn: Button = $BottomRightContainer/DevicePanel/MainVBox/EmotionsHBox/HopeBtn
@onready var anger_btn: Button = $BottomRightContainer/DevicePanel/MainVBox/EmotionsHBox/AngerBtn
@onready var acceptance_btn: Button = $BottomRightContainer/DevicePanel/MainVBox/EmotionsHBox/AcceptanceBtn
@onready var stop_button: Button = $BottomRightContainer/DevicePanel/MainVBox/StopButton

func _ready() -> void:
	hope_btn.pressed.connect(func(): EmotionManager.select_emotion("HOPE"))
	anger_btn.pressed.connect(func(): EmotionManager.select_emotion("ANGER"))
	acceptance_btn.pressed.connect(func(): EmotionManager.select_emotion("ACCEPTANCE"))
	stop_button.pressed.connect(_on_stop_pressed)
	
	EmotionManager.active_emotion_changed.connect(_on_active_emotion_changed)
	EmotionManager.unlocked_emotions_changed.connect(_on_unlocked_changed)
	
	if GameManager.has_signal("chapter_changed"):
		GameManager.chapter_changed.connect(_on_chapter_changed)
	if GameManager.has_signal("act_changed"):
		GameManager.act_changed.connect(func(_act): _on_chapter_changed(_act * 3))
	
	_update_hud()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed):
		return
		
	if event.keycode == KEY_1 or event.keycode == KEY_KP_1:
		if EmotionManager.is_emotion_unlocked("HOPE"):
			EmotionManager.select_emotion("HOPE")
	elif event.keycode == KEY_2 or event.keycode == KEY_KP_2:
		if EmotionManager.is_emotion_unlocked("ANGER"):
			EmotionManager.select_emotion("ANGER")
	elif event.keycode == KEY_3 or event.keycode == KEY_KP_3:
		if EmotionManager.is_emotion_unlocked("ACCEPTANCE"):
			EmotionManager.select_emotion("ACCEPTANCE")
	elif event.keycode == KEY_F:
		cast_requested.emit()

func _on_active_emotion_changed(_emotion: String) -> void:
	_update_hud()

func _on_unlocked_changed() -> void:
	_update_hud()

func _on_chapter_changed(chap: int) -> void:
	if chap >= 6 or GameManager.active_act >= 2:
		stop_button.visible = true
	_update_hud()

func _update_hud() -> void:
	var active = EmotionManager.active_emotion
	if active == "NONE":
		status_label.text = "Active: NONE | Press [1,2,3] to select, [F] to Cast"
	else:
		status_label.text = "ACTIVE: [" + active + "] | Press [F] to Cast Frequency"
		
	_update_btn(hope_btn, "HOPE", "[1] 🔵 HOPE", active == "HOPE")
	_update_btn(anger_btn, "ANGER", "[2] 🔴 ANGER", active == "ANGER")
	_update_btn(acceptance_btn, "ACCEPTANCE", "[3] 🟡 ACCEPTANCE", active == "ACCEPTANCE")
	
	if GameManager.active_act >= 2 or GameManager.active_chapter >= 6:
		stop_button.visible = true

func _update_btn(btn: Button, emotion: String, label_text: String, is_active: bool) -> void:
	var is_unlocked = EmotionManager.is_emotion_unlocked(emotion)
	if is_unlocked:
		btn.text = label_text
		btn.disabled = false
		if is_active:
			btn.modulate = Color(1.5, 1.5, 0.4, 1.0)
		else:
			btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		btn.text = emotion + " [LOCKED]"
		btn.disabled = true
		btn.modulate = Color(0.5, 0.5, 0.5, 0.6)

func _on_stop_pressed() -> void:
	print("[ResonanceHUD] Player pressed permanent STOP button!")
	GameManager.player_pressed_stop_button = true
	stop_button.disabled = true
	stop_button.text = "🛑 SHUTDOWN EXECUTED"
	GameManager.change_location("FINAL_CLIMAX")
