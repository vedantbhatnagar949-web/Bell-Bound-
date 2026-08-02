extends CanvasLayer
## Visual Novel Dialogue UI — Character centered, name + dialogue at bottom, player input below.
## Inspired by classic VN style (Innkeeper reference).

signal dialogue_finished

var dialogue_root: Control

# UI nodes
var darken_overlay: ColorRect      # Slight darkening behind character
var character_sprite: TextureRect  # Centered character portrait (large, waist up)
var text_panel: Panel              # Semi-transparent bottom panel
var name_label: Label              # Character name (colored)
var message_label: Label           # Dialogue text
var continue_btn: Button           # Invisible click-to-advance overlay
var close_btn: Button              # Close X

var player_panel: Panel            # Player input panel (below dialogue)
var player_input: LineEdit         # Text input
var send_btn: Button               # Send button

var typewriter_node = null
var current_speaker: String = ""
var current_lines: Array[String] = []
var current_line_idx: int = 0
var _is_open: bool = false

var valid_ai_npcs: Array[String] = ["Toby", "Arthur", "Evelyn", "Victor"]
var character_textures: Dictionary = {
	"Toby": "res://Toby.png",
	"Arthur": "res://Old Man.png",
	"Evelyn": "res://Teacher.png",
	"Victor": "res://Mechanic.png"
}
var character_colors: Dictionary = {
	"Toby": Color(0.4, 0.85, 1.0),
	"Arthur": Color(0.95, 0.75, 0.4),
	"Evelyn": Color(0.6, 0.9, 0.5),
	"Victor": Color(0.9, 0.5, 0.4),
	"System": Color(0.85, 0.85, 0.85)
}

func _ready() -> void:
	visible = false
	dialogue_root = $DialogueRoot
	_build_ui()
	
	# Typewriter
	var tw_script = load("res://scripts/ui/TypewriterEffect.gd")
	typewriter_node = tw_script.new()
	add_child(typewriter_node)
	typewriter_node.setup(message_label)
	typewriter_node.typewriter_finished.connect(func(): pass)

func _build_ui() -> void:
	var vp = get_viewport().get_visible_rect().size
	if vp == Vector2.ZERO:
		vp = Vector2(1024, 600)
	
	# ── Dark overlay behind character (subtle dim) ──
	darken_overlay = ColorRect.new()
	darken_overlay.name = "DarkenOverlay"
	darken_overlay.color = Color(0, 0, 0, 0.3)
	darken_overlay.position = Vector2.ZERO
	darken_overlay.size = vp
	darken_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialogue_root.add_child(darken_overlay)
	
	# ── Character Sprite (centered, large, bottom-aligned) ──
	var char_w = vp.x * 0.45
	var char_h = vp.y * 0.75
	character_sprite = TextureRect.new()
	character_sprite.name = "CharacterSprite"
	character_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	character_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	character_sprite.position = Vector2((vp.x - char_w) / 2.0, vp.y - char_h - 80.0)
	character_sprite.size = Vector2(char_w, char_h)
	character_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialogue_root.add_child(character_sprite)
	
	# ── Bottom text panel (semi-transparent dark) ──
	var panel_h = 120.0
	var panel_y = vp.y - panel_h - 50.0
	text_panel = Panel.new()
	text_panel.name = "TextPanel"
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.7)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 24.0
	style.content_margin_right = 24.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	text_panel.add_theme_stylebox_override("panel", style)
	text_panel.position = Vector2(vp.x * 0.05, panel_y)
	text_panel.size = Vector2(vp.x * 0.9, panel_h)
	dialogue_root.add_child(text_panel)
	
	# ── Name Label (colored, above dialogue text) ──
	name_label = Label.new()
	name_label.name = "NameLabel"
	name_label.text = "Toby"
	name_label.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0))
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.position = Vector2(24.0, 8.0)
	name_label.size = Vector2(text_panel.size.x - 80.0, 30.0)
	text_panel.add_child(name_label)
	
	# ── Dialogue Message Label ──
	message_label = Label.new()
	message_label.name = "MessageLabel"
	message_label.text = ""
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
	message_label.add_theme_font_size_override("font_size", 17)
	message_label.position = Vector2(28.0, 40.0)
	message_label.size = Vector2(text_panel.size.x - 56.0, panel_h - 50.0)
	text_panel.add_child(message_label)
	
	# ── Click-to-advance overlay (covers text panel) ──
	continue_btn = Button.new()
	continue_btn.name = "ContinueBtn"
	continue_btn.flat = true
	continue_btn.modulate = Color(1, 1, 1, 0)
	continue_btn.position = Vector2.ZERO
	continue_btn.size = text_panel.size
	continue_btn.pressed.connect(_on_continue_pressed)
	text_panel.add_child(continue_btn)
	
	# ── Close button (top-right of text panel) ──
	close_btn = Button.new()
	close_btn.name = "CloseBtn"
	close_btn.text = "✖"
	close_btn.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	close_btn.add_theme_font_size_override("font_size", 16)
	close_btn.flat = true
	close_btn.position = Vector2(text_panel.size.x - 40.0, 4.0)
	close_btn.size = Vector2(32.0, 32.0)
	close_btn.pressed.connect(_end_dialogue)
	text_panel.add_child(close_btn)
	
	# ── Player Input Panel (below text panel) ──
	var input_h = 44.0
	player_panel = Panel.new()
	player_panel.name = "PlayerPanel"
	var input_style = StyleBoxFlat.new()
	input_style.bg_color = Color(0.12, 0.12, 0.18, 0.85)
	input_style.corner_radius_bottom_left = 8
	input_style.corner_radius_bottom_right = 8
	player_panel.add_theme_stylebox_override("panel", input_style)
	player_panel.position = Vector2(vp.x * 0.05, panel_y + panel_h + 4.0)
	player_panel.size = Vector2(vp.x * 0.9, input_h)
	player_panel.visible = false
	dialogue_root.add_child(player_panel)
	
	# ── Player Input (inside player panel) ──
	player_input = LineEdit.new()
	player_input.name = "PlayerInput"
	player_input.placeholder_text = "Type your message..."
	var le_style = StyleBoxFlat.new()
	le_style.bg_color = Color(0.2, 0.2, 0.28, 0.6)
	le_style.corner_radius_top_left = 4
	le_style.corner_radius_top_right = 4
	le_style.corner_radius_bottom_left = 4
	le_style.corner_radius_bottom_right = 4
	player_input.add_theme_stylebox_override("normal", le_style)
	player_input.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	player_input.add_theme_color_override("font_placeholder_color", Color(0.6, 0.6, 0.7, 0.7))
	player_input.add_theme_font_size_override("font_size", 14)
	player_input.position = Vector2(12.0, 7.0)
	player_input.size = Vector2(player_panel.size.x - 90.0, 30.0)
	player_input.text_submitted.connect(func(_t): _on_send_pressed())
	player_panel.add_child(player_input)
	
	# ── Send Button ──
	send_btn = Button.new()
	send_btn.name = "SendBtn"
	send_btn.text = "Send"
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.25, 0.5, 0.8, 0.9)
	btn_style.corner_radius_top_left = 4
	btn_style.corner_radius_top_right = 4
	btn_style.corner_radius_bottom_left = 4
	btn_style.corner_radius_bottom_right = 4
	send_btn.add_theme_stylebox_override("normal", btn_style)
	send_btn.add_theme_color_override("font_color", Color(1, 1, 1))
	send_btn.add_theme_font_size_override("font_size", 14)
	send_btn.position = Vector2(player_panel.size.x - 72.0, 7.0)
	send_btn.size = Vector2(60.0, 30.0)
	send_btn.pressed.connect(_on_send_pressed)
	player_panel.add_child(send_btn)

func _process(delta: float) -> void:
	if not visible:
		return
	if typewriter_node:
		typewriter_node.process_typewriter(delta)

# ═══════════════════════════════════════════
#  PUBLIC API
# ═══════════════════════════════════════════

func start_dialogue(speaker_name: String, text_or_lines: Variant, emotion: String = "neutral") -> void:
	current_speaker = speaker_name
	name_label.text = speaker_name
	name_label.add_theme_color_override("font_color", character_colors.get(speaker_name, Color(0.85, 0.85, 0.85)))
	
	# Set character portrait
	_set_portrait(speaker_name)
	
	# Parse text
	var raw: String = ""
	if typeof(text_or_lines) == TYPE_STRING:
		raw = text_or_lines
	elif typeof(text_or_lines) == TYPE_ARRAY and text_or_lines.size() > 0:
		raw = " ".join(text_or_lines)
	else:
		raw = str(text_or_lines)
	
	current_lines = _chunk_text(raw, 90)  # ~90 chars per page
	current_line_idx = 0
	
	if not _is_open:
		_is_open = true
		visible = true
		_animate_in()
	
	_show_line()
	_update_player_panel()

# ═══════════════════════════════════════════
#  INTERNALS
# ═══════════════════════════════════════════

func _set_portrait(char_name: String) -> void:
	var path = character_textures.get(char_name, "")
	if path != "" and ResourceLoader.exists(path):
		character_sprite.texture = load(path) as Texture2D
		character_sprite.visible = true
	else:
		character_sprite.visible = false

func _chunk_text(text: String, chars_per_page: int) -> Array[String]:
	var words = text.strip_edges().split(" ")
	var pages: Array[String] = []
	var current_page: String = ""
	for w in words:
		if w.strip_edges() == "":
			continue
		var test = current_page + (" " if current_page != "" else "") + w
		if test.length() > chars_per_page and current_page != "":
			pages.append(current_page)
			current_page = w
		else:
			current_page = test
	if current_page != "":
		pages.append(current_page)
	if pages.size() == 0:
		pages.append("...")
	return pages

func _show_line() -> void:
	if current_line_idx < current_lines.size():
		typewriter_node.start_typing(current_lines[current_line_idx], 0.02)

func _on_continue_pressed() -> void:
	if typewriter_node and typewriter_node.is_typing:
		typewriter_node.skip()
	else:
		current_line_idx += 1
		if current_line_idx < current_lines.size():
			_show_line()
		else:
			_end_dialogue()

func _update_player_panel() -> void:
	var is_ai = valid_ai_npcs.has(current_speaker)
	if is_ai:
		player_panel.visible = true
		player_panel.modulate.a = 1.0
	else:
		player_panel.visible = false

func _on_send_pressed() -> void:
	if player_input and player_input.text.strip_edges() != "":
		var query = player_input.text.strip_edges()
		player_input.text = ""
		GameManager.register_conversation()
		GeminiManager.generate_npc_dialogue(current_speaker, query)

func _animate_in() -> void:
	# Fade in everything
	darken_overlay.modulate.a = 0.0
	character_sprite.modulate.a = 0.0
	text_panel.modulate.a = 0.0
	player_panel.modulate.a = 0.0
	
	# Character slides up slightly
	character_sprite.position.y += 40.0
	var orig_char_y = character_sprite.position.y - 40.0
	
	var tw = create_tween().set_parallel(true)
	tw.tween_property(darken_overlay, "modulate:a", 1.0, 0.2)
	tw.tween_property(character_sprite, "modulate:a", 1.0, 0.3)
	tw.tween_property(character_sprite, "position:y", orig_char_y, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(text_panel, "modulate:a", 1.0, 0.25).set_delay(0.1)
	tw.tween_property(player_panel, "modulate:a", 1.0, 0.25).set_delay(0.15)

func _end_dialogue() -> void:
	if not _is_open:
		return
	var tw = create_tween().set_parallel(true)
	tw.tween_property(darken_overlay, "modulate:a", 0.0, 0.2)
	tw.tween_property(character_sprite, "modulate:a", 0.0, 0.2)
	tw.tween_property(text_panel, "modulate:a", 0.0, 0.15)
	tw.tween_property(player_panel, "modulate:a", 0.0, 0.15)
	await tw.finished
	visible = false
	_is_open = false
	player_panel.visible = false
	dialogue_finished.emit()
