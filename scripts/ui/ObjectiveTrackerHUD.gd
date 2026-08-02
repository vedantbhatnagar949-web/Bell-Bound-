extends CanvasLayer

@onready var objective_label: Label = $TopLeftContainer/Panel/VBox/ObjectiveLabel

func _ready() -> void:
	if GameManager.has_signal("act_changed"):
		GameManager.act_changed.connect(_on_act_changed)
	_update_objective()

func _on_act_changed(_act: int) -> void:
	_update_objective()

func _update_objective() -> void:
	var act = GameManager.active_act
	match act:
		1:
			var solved_count = GameManager.completed_puzzles.size()
			objective_label.text = "ACT 1: THE RESONANT VILLAGE (" + str(solved_count) + "/4 Solved)\nTalk to & Help Toby (Music Box), Arthur (Photo), Evelyn (Board), Victor (Valve)."
		2:
			objective_label.text = "ACT 2: THE WHISPERING SECRETS\nInvestigate the Bell Tree & Underground Lab to uncover the secret of the Mother & Player."
		3:
			objective_label.text = "ACT 3: THE RESONANT CLIMAX\nThe village stands at the brink of truth. Make your final choice!"
		_:
			objective_label.text = "Explore the village of Bell Bound."
