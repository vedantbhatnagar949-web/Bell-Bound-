extends Node

signal location_changed(location_id: String)
signal act_changed(act_number: int)
signal chapter_changed(chapter_number: int)
signal puzzle_completed(puzzle_id: String)
signal npc_memory_updated(npc_name: String, new_memory: String)
signal relationship_changed(npc_name: String, trust_score: int, status_name: String)

var current_location: String = "MAIN_MENU"
var active_act: int = 1
var active_chapter: int = 1
var village_mood: String = "NORMAL"

var player_pressed_stop_button: bool = false
var player_chose_sacrifice: bool = false

var total_conversations_had: int = 0
var total_projections_made: int = 0
var completed_puzzles: Array = []

# Compulsory Dialogue Tracking
var has_talked_to_npc: Dictionary = {
	"Toby": false,
	"Arthur": false,
	"Evelyn": false,
	"Victor": false
}

var unlocked_locations: Dictionary = {
	"MAIN_MENU": true,
	"VILLAGE_OVERVIEW": false,
	"CHILD_HOUSE": true,
	"OLD_MAN_HOUSE": true,
	"TEACHER_HOUSE": true,
	"ENGINEER_WORKSHOP": true,
	"BELL_TREE": false,
	"FROZEN_LABORATORY": false,
	"BELL_TOWER_ROOM": true,
	"FINAL_CLIMAX": true
}

# Dynamic NPC Wander Locations
var npc_locations: Dictionary = {
	"Toby": "CHILD_HOUSE",
	"Arthur": "OLD_MAN_HOUSE",
	"Evelyn": "TEACHER_HOUSE",
	"Victor": "ENGINEER_WORKSHOP"
}

# NPC Emotional Memories & Relationship Core (0-100 Trust Score)
var npc_data: Dictionary = {
	"Toby": {
		"current_emotion": "NEUTRAL",
		"trust": 50,
		"projection_history": [],
		"memories": [
			"My mother left me a music box before she vanished into the mountain peaks."
		]
	},
	"Arthur": {
		"current_emotion": "NEUTRAL",
		"trust": 50,
		"projection_history": [],
		"memories": [
			"The elders sealed the village memories inside the resonance frequency years ago."
		]
	},
	"Evelyn": {
		"current_emotion": "NEUTRAL",
		"trust": 50,
		"projection_history": [],
		"memories": [
			"The schoolhouse chalkboard conceals suppressed village records."
		]
	},
	"Victor": {
		"current_emotion": "NEUTRAL",
		"trust": 50,
		"projection_history": [],
		"memories": [
			"The steam engine regulates the pressure valve leading to the Bell Tree."
		]
	}
}

func _ready() -> void:
	print("[BELL BOUND] GameManager ready with 3-ACT & AI Relationship Core.")

func change_location(new_location: String) -> void:
	current_location = new_location
	_update_npc_wander_positions()
	location_changed.emit(new_location)
	print("[GameManager] Transitioning location to: ", new_location)
	
	var scene_path: String = ""
	match new_location:
		"MAIN_MENU":
			scene_path = "res://scenes/menu/MainMenu.tscn"
		"CHILD_HOUSE":
			scene_path = "res://scenes/child_house/ChildHouse.tscn"
		"OLD_MAN_HOUSE":
			scene_path = "res://scenes/oldman_house/OldManHouse.tscn"
		"TEACHER_HOUSE":
			scene_path = "res://scenes/teacher_house/TeacherHouse.tscn"
		"ENGINEER_WORKSHOP":
			scene_path = "res://scenes/engineer/EngineerWorkshop.tscn"
		"BELL_TREE":
			scene_path = "res://scenes/bell_tree/BellTree.tscn"
		"FROZEN_LABORATORY":
			scene_path = "res://scenes/world/locations/FrozenLaboratory.tscn"
		"BELL_TOWER_ROOM":
			scene_path = "res://scenes/bell_tower/BellTowerRoom.tscn"
		"FINAL_CLIMAX":
			scene_path = "res://scenes/bell_tree/FinalClimax.tscn"
		_:
			scene_path = "res://scenes/child_house/ChildHouse.tscn"
			
	if scene_path != "" and ResourceLoader.exists(scene_path):
		get_tree().change_scene_to_file(scene_path)

func mark_npc_talked(npc_name: String) -> void:
	has_talked_to_npc[npc_name] = true
	total_conversations_had += 1
	print("[GameManager] Mark NPC talked: ", npc_name, " (Total: ", total_conversations_had, ")")
	_check_act_progression()

func register_conversation() -> void:
	total_conversations_had += 1
	print("[GameManager] Conversation registered. Total: ", total_conversations_had)
	_check_act_progression()

func get_relationship_status(npc_name: String) -> String:
	var trust = npc_data.get(npc_name, {}).get("trust", 50)
	if trust < 30:
		return "DISTRUSTFUL (" + str(trust) + "/100)"
	elif trust < 60:
		return "NEUTRAL (" + str(trust) + "/100)"
	elif trust < 85:
		return "FRIENDLY (" + str(trust) + "/100)"
	else:
		return "TRUSTING (" + str(trust) + "/100)"

func update_relationship_trust(npc_name: String, change_delta: int) -> void:
	if npc_data.has(npc_name):
		var current_trust = npc_data[npc_name].get("trust", 50)
		var new_trust = clamp(current_trust + change_delta, 0, 100)
		npc_data[npc_name]["trust"] = new_trust
		var status_str = get_relationship_status(npc_name)
		relationship_changed.emit(npc_name, new_trust, status_str)
		print("[Relationship Core] Updated ", npc_name, " Trust -> ", new_trust, " (", status_str, ")")

func _update_npc_wander_positions() -> void:
	# NPCs are ALWAYS at their home. They can ALSO visit other locations.
	# This ensures Talk buttons always appear at home locations.
	npc_locations["Toby"] = "CHILD_HOUSE"
	npc_locations["Arthur"] = "OLD_MAN_HOUSE"
	npc_locations["Evelyn"] = "TEACHER_HOUSE"
	if active_act >= 2:
		npc_locations["Victor"] = "FROZEN_LABORATORY"
	else:
		npc_locations["Victor"] = "ENGINEER_WORKSHOP"

func is_npc_present_at(npc_name: String, location_id: String) -> bool:
	return npc_locations.get(npc_name, "") == location_id

func get_npc_location_name(npc_name: String) -> String:
	var loc_id = npc_locations.get(npc_name, "CHILD_HOUSE")
	match loc_id:
		"CHILD_HOUSE": return "Toby's Cottage"
		"OLD_MAN_HOUSE": return "Arthur's Cottage"
		"TEACHER_HOUSE": return "The Schoolhouse"
		"ENGINEER_WORKSHOP": return "The Workshop"
		"FROZEN_LABORATORY": return "The Frozen Lab"
		_: return "the village"

func complete_puzzle(puzzle_id: String) -> void:
	if not completed_puzzles.has(puzzle_id):
		completed_puzzles.append(puzzle_id)
		puzzle_completed.emit(puzzle_id)
		print("[GameManager] Puzzle completed: ", puzzle_id)
		_check_act_progression()

func _check_act_progression() -> void:
	# ACT 1 -> ACT 2 Progression
	if active_act == 1 and completed_puzzles.size() >= 4:
		advance_act(2)
		unlock_location("BELL_TREE")
		unlock_location("FROZEN_LABORATORY")

func advance_act(new_act: int) -> void:
	active_act = new_act
	active_chapter = new_act * 3 # Backwards compatibility mapping
	act_changed.emit(new_act)
	chapter_changed.emit(active_chapter)
	print("[GameManager] Story advanced to ACT ", new_act)

func advance_chapter(new_chap: int) -> void:
	active_chapter = new_chap
	chapter_changed.emit(new_chap)

func record_emotion_projection(npc_name: String, emotion: String) -> void:
	total_projections_made += 1
	if not npc_data.has(npc_name):
		return
		
	var data = npc_data[npc_name]
	data["current_emotion"] = emotion
	data["projection_history"].append(emotion)
	
	var memory_entry = "Player projected " + emotion + " frequency into " + npc_name + "."
	data["memories"].append(memory_entry)
	npc_memory_updated.emit(npc_name, memory_entry)
	print("[GameManager] Recorded ", emotion, " projection on ", npc_name)
	
	if total_projections_made >= 1:
		EmotionManager.unlock_emotion("ANGER")
	if total_projections_made >= 3:
		EmotionManager.unlock_emotion("ACCEPTANCE")

func unlock_location(loc_id: String) -> void:
	unlocked_locations[loc_id] = true

func is_location_unlocked(loc_id: String) -> bool:
	return unlocked_locations.get(loc_id, false)
