extends Node

signal active_emotion_changed(emotion: String)
signal unlocked_emotions_changed
signal emotion_projected(target_name: String, emotion: String)

var active_emotion: String = "NONE" # "HOPE", "ANGER", "ACCEPTANCE", "NONE"

var unlocked_emotions: Dictionary = {
	"HOPE": true,
	"ANGER": false,
	"ACCEPTANCE": false
}

func _ready() -> void:
	print("[BELL BOUND] EmotionManager initialized with progressive locks.")

func select_emotion(emotion: String) -> void:
	var upper_emotion = emotion.to_upper()
	if not is_emotion_unlocked(upper_emotion):
		print("[EmotionManager] Emotion ", upper_emotion, " is still LOCKED.")
		return
		
	if active_emotion == upper_emotion:
		active_emotion = "NONE" # Toggle off
	else:
		active_emotion = upper_emotion
		
	active_emotion_changed.emit(active_emotion)
	print("[EmotionManager] Active Resonance frequency: ", active_emotion)

func unlock_emotion(emotion: String) -> void:
	var upper_emotion = emotion.to_upper()
	if unlocked_emotions.has(upper_emotion) and not unlocked_emotions[upper_emotion]:
		unlocked_emotions[upper_emotion] = true
		unlocked_emotions_changed.emit()
		print("[EmotionManager] Unlocked emotion frequency: ", upper_emotion)

func is_emotion_unlocked(emotion: String) -> bool:
	return unlocked_emotions.get(emotion.to_upper(), false)

func project_emotion_on_target(target_name: String) -> String:
	if active_emotion == "NONE":
		print("[EmotionManager] No active emotion selected!")
		return "NONE"
		
	print("[EmotionManager] Projecting ", active_emotion, " frequency onto ", target_name)
	emotion_projected.emit(target_name, active_emotion)
	GameManager.record_emotion_projection(target_name, active_emotion)
	return active_emotion
