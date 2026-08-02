extends Node

enum Chapter {
	CHAPTER_1_CHILD,
	CHAPTER_2_OLD_MAN,
	CHAPTER_3_TEACHER,
	CHAPTER_4_ENGINEER,
	CHAPTER_5_MIDGAME,
	CHAPTER_6_BELL_TREE,
	CHAPTER_7_FROZEN_LAB,
	FINAL_CLIMAX
}

var current_chapter: Chapter = Chapter.CHAPTER_1_CHILD
var chapter_titles: Array[String] = [
	"Chapter 1: The Child (Hope)",
	"Chapter 2: The Old Man (Acceptance)",
	"Chapter 3: The Teacher (Anger)",
	"Chapter 4: The Engineer (Fear)",
	"Chapter 5: The Unsettling Silence",
	"Chapter 6: The Bell Tree Echoes",
	"Chapter 7: The Frozen Truth",
	"Final Chapter: Bell Bound"
]

func _ready() -> void:
	print("[BELL BOUND] StoryManager ready.")
	if GameManager.has_signal("puzzle_completed"):
		GameManager.puzzle_completed.connect(_on_puzzle_completed)

func advance_chapter() -> void:
	if current_chapter < Chapter.FINAL_CLIMAX:
		current_chapter = (current_chapter + 1) as Chapter
		GameManager.active_chapter = current_chapter + 1
		_apply_chapter_unlocks()
		GameManager.chapter_changed.emit(GameManager.active_chapter)
		print("[StoryManager] Advanced to: ", chapter_titles[current_chapter])

func _apply_chapter_unlocks() -> void:
	match current_chapter:
		Chapter.CHAPTER_2_OLD_MAN:
			GameManager.unlock_location("OLD_MAN_HOUSE")
		Chapter.CHAPTER_3_TEACHER:
			GameManager.unlock_location("TEACHER_HOUSE")
		Chapter.CHAPTER_4_ENGINEER:
			GameManager.unlock_location("ENGINEER_WORKSHOP")
		Chapter.CHAPTER_5_MIDGAME:
			GameManager.set_village_mood("SUSPICIOUS")
			GameManager.unlock_location("BELL_TREE")
		Chapter.CHAPTER_6_BELL_TREE:
			GameManager.unlock_location("BELL_TREE")
		Chapter.CHAPTER_7_FROZEN_LAB:
			GameManager.unlock_location("FROZEN_LABORATORY")
		Chapter.FINAL_CLIMAX:
			GameManager.unlock_location("FINAL_CLIMAX")

func get_current_chapter_title() -> String:
	return chapter_titles[current_chapter]

func _on_puzzle_completed(puzzle_id: String) -> void:
	match puzzle_id:
		"music_box_repair":
			EmotionManager.unlock_emotion("HOPE")
			advance_chapter()
		"photograph_puzzle":
			EmotionManager.unlock_emotion("ACCEPTANCE")
			advance_chapter()
		"classroom_cipher":
			EmotionManager.unlock_emotion("ANGER")
			advance_chapter()
		"mechanical_gears":
			EmotionManager.unlock_emotion("FEAR")
			advance_chapter()
		"bell_rope_mechanism":
			advance_chapter()
		"frozen_lab_journal":
			advance_chapter()
