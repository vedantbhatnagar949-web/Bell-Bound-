extends Node

signal response_received(speaker_name: String, dialogue_text: String)

var groq_api_key: String = "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"
var http_request: HTTPRequest
var current_target_npc: String = "Toby"
var last_player_message: String = ""

# Models to attempt on Groq Cloud
var groq_models: Array[String] = ["llama-3.3-70b-versatile", "llama-3.1-8b-instant", "mixtral-8x7b-32768"]
var current_model_index: int = 0

func _ready() -> void:
	print("[BELL BOUND] GeminiManager initialized with Groq Cloud Relationship Core.")
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

func generate_npc_dialogue(npc_name: String, player_message: String = "") -> void:
	current_target_npc = npc_name
	last_player_message = player_message
	current_model_index = 0
	
	# Mark compulsory conversation finished in GameManager
	GameManager.mark_npc_talked(npc_name)
	
	# Evaluate simple sentiment boost for relationship tracking
	_evaluate_sentiment_boost(npc_name, player_message)
	
	_send_groq_request()

func _evaluate_sentiment_boost(npc_name: String, player_msg: String) -> void:
	var msg_lower = player_msg.strip_edges().to_lower()
	if msg_lower == "": return
	
	var positive_words = ["help", "friend", "thank", "love", "care", "safe", "kind", "good", "happy", "yes", "please"]
	var negative_words = ["hate", "fool", "shut up", "stupid", "bad", "liar", "go away", "destroy", "scare"]
	
	var delta = 0
	for word in positive_words:
		if msg_lower.contains(word):
			delta += 5
			
	for word in negative_words:
		if msg_lower.contains(word):
			delta -= 8
			
	if delta != 0:
		GameManager.update_relationship_trust(npc_name, delta)

func _send_groq_request() -> void:
	var npc_info = GameManager.npc_data.get(current_target_npc, {})
	var current_emotion = npc_info.get("current_emotion", "NEUTRAL")
	var memories = npc_info.get("memories", [])
	var rel_status = GameManager.get_relationship_status(current_target_npc)
	
	# Construct systemic persona prompt for Groq Cloud
	var persona_desc: String = ""
	match current_target_npc:
		"Toby":
			persona_desc = "9-year-old child living in a frozen mountain village. Innocent, curious, misses his mother."
		"Arthur":
			persona_desc = "Elderly nostalgic grandfather. Speaks slowly, feels lonely when ignored, carries memories of the old village."
		"Evelyn":
			persona_desc = "Passionate schoolteacher. Defiant against elder censorship, protective of children."
		"Victor":
			persona_desc = "Gruff steam mechanical engineer. Focused on gears, pressure valves, and machines."
		_:
			persona_desc = "Mountain villager."

	var system_prompt = "You are playing " + current_target_npc + ", a fantasy character in the video game 'Bell Bound'.\n"
	system_prompt += "Persona: " + persona_desc + "\n"
	system_prompt += "Current Emotion State: " + current_emotion + "\n"
	system_prompt += "Relationship Trust with Player: " + rel_status + "\n"
	system_prompt += "Memories & History: " + str(memories) + "\n"
	system_prompt += "STRICT RULES:\n"
	system_prompt += "1. Speak 100% in character for a frozen fantasy mountain world! You have ZERO knowledge of real-world computers, programming, modern tech, or real-world brands.\n"
	system_prompt += "2. If the player asks about unknown out-of-world concepts (like 'What is HTML?', 'What is Python?', 'What is Linux?'), respond DIEGETICALLY saying you don't know or interpreting it naturally from your persona (e.g. Toby (child) thinks HTML is elder magic; Python is a scary snake; Victor thinks it is a mechanical steam pipe).\n"
	system_prompt += "3. Reflect your relationship status (" + rel_status + ") and active emotion (" + current_emotion + ") in tone and word choice.\n"
	system_prompt += "4. MAXIMUM CAP: Respond in 1 to 3 lines maximum. Return ONLY the spoken character dialogue."

	var user_prompt = last_player_message
	if user_prompt.strip_edges() == "":
		user_prompt = "Greetings. What are you thinking about right now under your active emotion (" + current_emotion + ")?"

	var selected_model = groq_models[current_model_index]
	print("[Groq AI Dispatch] Model: ", selected_model, " for NPC: ", current_target_npc)

	var url = "https://api.groq.com/openai/v1/chat/completions"
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + groq_api_key
	]
	
	var payload = {
		"model": selected_model,
		"messages": [
			{
				"role": "system",
				"content": system_prompt
			},
			{
				"role": "user",
				"content": user_prompt
			}
		],
		"max_tokens": 100,
		"temperature": 0.7
	}

	var json_string = JSON.stringify(payload)
	var err = http_request.request(url, headers, HTTPClient.METHOD_POST, json_string)
	if err != OK:
		_attempt_next_model_or_fallback()

func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		var json = JSON.new()
		var parse_err = json.parse(body.get_string_from_utf8())
		if parse_err == OK:
			var data = json.get_data()
			if data.has("choices") and data["choices"].size() > 0:
				var choice = data["choices"][0]
				if choice.has("message") and choice["message"].has("content"):
					var ai_text = choice["message"]["content"].strip_edges()
					var lines = ai_text.split("\n")
					if lines.size() > 3:
						ai_text = lines[0] + "\n" + lines[1] + "\n" + lines[2]
					print("[Groq AI LIVE SUCCESS] Response: ", ai_text)
					response_received.emit(current_target_npc, ai_text)
					return
					
	print("[Groq API Response Code: ", response_code, "] Body: ", body.get_string_from_utf8())
	_attempt_next_model_or_fallback()

func _attempt_next_model_or_fallback() -> void:
	current_model_index += 1
	if current_model_index < groq_models.size():
		print("[Groq Retry] Trying failover model ", groq_models[current_model_index])
		_send_groq_request()
	else:
		var npc_info = GameManager.npc_data.get(current_target_npc, {})
		var current_emotion = npc_info.get("current_emotion", "NEUTRAL")
		var memories = npc_info.get("memories", [])
		_seamless_generative_engine(current_target_npc, current_emotion, memories, last_player_message)

# SEAMLESS DYNAMIC GENERATIVE ENGINE
func _seamless_generative_engine(npc_name: String, emotion: String, memories: Array, player_msg: String = "") -> void:
	var msg_lower = player_msg.strip_edges().to_lower()
	var dialogue_output: String = ""
	
	# 1. Out-of-World / Unknown Term Intent
	var is_unknown = false
	var unknown_words = ["html", "css", "python", "javascript", "code", "ai", "linux", "computer", "java", "software"]
	for word in unknown_words:
		if msg_lower.contains(word):
			is_unknown = true
			break
			
	if is_unknown:
		match npc_name:
			"Toby":
				dialogue_output = "I haven't heard of that in our mountain valley... I only know about the falling snow and my mother's old music box."
			"Arthur":
				dialogue_output = "That sounds like strange magic beyond my old ears. In my day, we only cared about firewood and warm soup."
			"Evelyn":
				dialogue_output = "I have not encountered that word in any of our schoolhouse lesson books. Why do you ask, traveler?"
			"Victor":
				dialogue_output = "I deal in steam, iron, and brass valves. Abstract words won't turn a frozen pressure manifold!"
			_:
				dialogue_output = "I know nothing of such words... the cold wind carries only silence here."
		response_received.emit(npc_name, dialogue_output)
		return

	# 2. Mother / Family Query Intent
	if msg_lower.contains("mother") or msg_lower.contains("mom") or msg_lower.contains("family"):
		match npc_name:
			"Toby":
				dialogue_output = "My mother... she used to sing sweet songs before she vanished into the mountain peaks. I miss her very much."
			"Arthur":
				dialogue_output = "Family is everything in this cold valley. I just wish my grandson Toby would visit his old grandpa more often."
			"Evelyn":
				dialogue_output = "We must protect our children and families from the silence the elders imposed on this village."
			"Victor":
				dialogue_output = "My father taught me how to work the steam engine. The machinery keeps this village alive."
		response_received.emit(npc_name, dialogue_output)
		return

	# 3. Emotion-Driven Dynamic Persona Responses
	match npc_name:
		"Toby":
			match emotion:
				"HOPE":
					var options = [
						"I feel a warm bright feeling inside me! I really think we can get the music box working again!",
						"The cold doesn't bother me right now... hope makes me feel like everything is going to be okay!"
					]
					dialogue_output = options[randi() % options.size()]
				"FEAR":
					var options = [
						"The room feels so quiet and dark... I'm scared to touch anything in case I ruin it.",
						"My hands are trembling... please don't leave me alone in the cold."
					]
					dialogue_output = options[randi() % options.size()]
				"ACCEPTANCE":
					var options = [
						"I'm sitting quietly watching the snow... maybe it's okay to just let things be.",
						"We can't change what happened yesterday... I'm at peace with the quiet now."
					]
					dialogue_output = options[randi() % options.size()]
				"ANGER":
					var options = [
						"Everything keeps failing! Why won't things just work the way they're supposed to?!",
						"I'm sick of waiting for help! I just want to smash everything that's broken!"
					]
					dialogue_output = options[randi() % options.size()]
				_:
					dialogue_output = "The snow is falling heavily outside... I was just sitting here thinking about my mother."

		"Arthur":
			match emotion:
				"HOPE":
					dialogue_output = "The snow can't freeze our memories forever. A spark of hope tells me the village will awaken again."
				"FEAR":
					dialogue_output = "Be careful near the old memory door... the elders sealed those rooms for a reason."
				"ACCEPTANCE":
					dialogue_output = "I am eighty years old and weary of fighting the past. Whatever happens, I accept it."
				"ANGER":
					dialogue_output = "The elders locked away our history and forced us into silence! I've had enough!"
				_:
					dialogue_output = "The room is quiet. Old memories linger like frost on the window panes."

		"Evelyn":
			match emotion:
				"HOPE":
					dialogue_output = "Hope gives us courage! We must teach the children the true history of our mountain village."
				"FEAR":
					dialogue_output = "Erase the chalkboard quickly! If the elders see what we wrote, they will seal the schoolhouse!"
				"ACCEPTANCE":
					dialogue_output = "The elders made their choices long ago. Some truths are heavy to carry, but we endure."
				"ANGER":
					dialogue_output = "They lied to us all! The elders stole our authentic feelings to keep the village quiet!"
				_:
					dialogue_output = "The chalkboard is blank under elder decree, but truth cannot be erased forever."

		"Victor":
			match emotion:
				"HOPE":
					dialogue_output = "The steam pressure is rising! Pushing the engine past its safe limit will open the mountain passage!"
				"FEAR":
					dialogue_output = "The pressure gauge is fluctuating! Shut down the valves before the manifold ruptures!"
				"ACCEPTANCE":
					dialogue_output = "The machinery is ancient beyond repair. I am dropping my wrench and walking away."
				"ANGER":
					dialogue_output = "They wanted power? I will jam the main valve open and blow the whole mechanism wide open!"
				_:
					dialogue_output = "The pressure system holds the mountain gate shut. Precision is required."

		_:
			dialogue_output = "The frozen wind echoes through the mountain village..."

	response_received.emit(npc_name, dialogue_output)
