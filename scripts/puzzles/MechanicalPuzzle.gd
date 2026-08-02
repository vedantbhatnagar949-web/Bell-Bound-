extends PuzzleBase

@onready var gauge_a: Button = $Panel/GaugeContainer/GaugeA
@onready var gauge_b: Button = $Panel/GaugeContainer/GaugeB
@onready var gauge_c: Button = $Panel/GaugeContainer/GaugeC
@onready var ignite_button: Button = $Panel/IgniteButton
@onready var status_label: Label = $Panel/StatusLabel
@onready var close_button: Button = $Panel/CloseButton

var gauge_pressures: Array[int] = [10, 10, 10]
var target_pressures: Array[int] = [30, 50, 20]

func _ready() -> void:
	puzzle_id = "mechanical_gears"
	puzzle_title = "The Mechanical Resonance Machine"
	
	gauge_a.pressed.connect(func(): _adjust_pressure(0, gauge_a))
	gauge_b.pressed.connect(func(): _adjust_pressure(1, gauge_b))
	gauge_c.pressed.connect(func(): _adjust_pressure(2, gauge_c))
	
	ignite_button.pressed.connect(_on_ignite_pressed)
	close_button.pressed.connect(close_puzzle)
	
	_update_gauge_labels()

func _adjust_pressure(idx: int, btn: Button) -> void:
	gauge_pressures[idx] = (gauge_pressures[idx] + 10)
	if gauge_pressures[idx] > 60:
		gauge_pressures[idx] = 10
	btn.text = "Gauge " + str(idx+1) + "\n" + str(gauge_pressures[idx]) + " PSI"
	status_label.text = "Adjusting steam pressure valve..."

func _update_gauge_labels() -> void:
	gauge_a.text = "Gauge I\n" + str(gauge_pressures[0]) + " PSI"
	gauge_b.text = "Gauge II\n" + str(gauge_pressures[1]) + " PSI"
	gauge_c.text = "Gauge III\n" + str(gauge_pressures[2]) + " PSI"

func _on_ignite_pressed() -> void:
	if gauge_pressures[0] == target_pressures[0] and gauge_pressures[1] == target_pressures[1] and gauge_pressures[2] == target_pressures[2]:
		status_label.text = "RESONANCE ENGAGED! Emotion 'FEAR' vibrates within the device."
		ignite_button.disabled = true
		await get_tree().create_timer(1.5).timeout
		solve_puzzle()
	else:
		status_label.text = "Pressure imbalance! Stream pressure fluctuates wildly."
