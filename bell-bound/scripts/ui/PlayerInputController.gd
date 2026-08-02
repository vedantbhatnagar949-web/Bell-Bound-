extends Control

@onready var message_board: Control = get_node_or_null("PlayerMessageBoard")
@onready var player_line_edit: LineEdit = get_node_or_null("PlayerMessageBoard/PlayerInput")
@onready var send_button: Button = get_node_or_null("PlayerMessageBoard/SendButton")

signal message_submitted(text: String)

var is_board_visible: bool = false

func _ready() -> void:
	if message_board:
		message_board.visible = false
		message_board.modulate.a = 0.0
	if player_line_edit:
		player_line_edit.text_submitted.connect(func(_txt): _on_send_pressed())
	if send_button:
		send_button.pressed.connect(_on_send_pressed)

func show_board() -> void:
	if not message_board or is_board_visible: return
	is_board_visible = true
	message_board.visible = true
	message_board.position.x += 120.0 # Start off-screen right
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(message_board, "position:x", message_board.position.x - 120.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(message_board, "modulate:a", 1.0, 0.25)

func hide_board() -> void:
	if not message_board or not is_board_visible: return
	is_board_visible = false
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(message_board, "position:x", message_board.position.x + 120.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(message_board, "modulate:a", 0.0, 0.25)
	await tween.finished
	message_board.visible = false

func _on_send_pressed() -> void:
	if player_line_edit and player_line_edit.text.strip_edges() != "":
		var text = player_line_edit.text.strip_edges()
		player_line_edit.text = ""
		message_submitted.emit(text)
