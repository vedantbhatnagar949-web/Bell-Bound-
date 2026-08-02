extends Node

signal npc_interacted(npc_id: String)
signal npc_mood_changed(npc_id: String, mood: String)

var active_npcs: Dictionary = {
	"child": {"name": "Lily", "location": "CHILD_HOUSE", "emotion": "HOPE", "trust": 50},
	"old_man": {"name": "Arthur", "location": "OLD_MAN_HOUSE", "emotion": "ACCEPTANCE", "trust": 40},
	"teacher": {"name": "Evelyn", "location": "TEACHER_HOUSE", "emotion": "ANGER", "trust": 30},
	"engineer": {"name": "Victor", "location": "ENGINEER_WORKSHOP", "emotion": "FEAR", "trust": 35}
}

func _ready() -> void:
	print("[BELL BOUND] NPCManager initialized.")

func get_npc_data(npc_id: String) -> Dictionary:
	return active_npcs.get(npc_id, {})

func interact_with_npc(npc_id: String) -> void:
	if active_npcs.has(npc_id):
		npc_interacted.emit(npc_id)
