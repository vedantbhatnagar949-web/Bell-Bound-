extends Control
## Simplified portrait controller — just swaps textures cleanly.

@onready var portrait_image: TextureRect = get_node_or_null("PortraitImage")
@onready var crossfade_image: TextureRect = get_node_or_null("CrossfadeImage")

var current_character: String = ""
var current_emotion: String = "neutral"

var character_textures: Dictionary = {
	"Toby": "res://Toby.png",
	"Arthur": "res://Old Man.png",
	"Evelyn": "res://Teacher.png",
	"Victor": "res://Mechanic.png"
}

func set_character(character_name: String, emotion: String = "neutral") -> void:
	current_character = character_name
	current_emotion = emotion.to_lower()
	var tex = _load_tex(character_name)
	if portrait_image:
		portrait_image.texture = tex

func _load_tex(char_name: String) -> Texture2D:
	if character_textures.has(char_name):
		var p = character_textures[char_name]
		if ResourceLoader.exists(p):
			return load(p) as Texture2D
	return load("res://Toby.png") as Texture2D
