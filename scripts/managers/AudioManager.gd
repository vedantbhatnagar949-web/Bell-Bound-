extends Node

var audio_player: AudioStreamPlayer
var generator: AudioStreamGenerator
var playback: AudioStreamGeneratorPlayback

var is_playing: bool = false
var tempo_fast: bool = false # false = low tempo, true = high tempo
var sample_rate: float = 44100.0
var phase: float = 0.0
var note_timer: float = 0.0

# Scale notes in Hz (all > 440 Hz): C5, D5, E5, G5, A5, C6
var melody_notes: Array[float] = [523.25, 587.33, 659.25, 783.99, 880.00, 1046.50]
var current_freq: float = 523.25
var target_freq: float = 523.25
var current_amp: float = 0.0

func _ready() -> void:
	print("[BELL BOUND] AudioManager initializing procedural peaceful BGM generator.")
	setup_audio_generator()
	start_bgm()

func setup_audio_generator() -> void:
	audio_player = AudioStreamPlayer.new()
	generator = AudioStreamGenerator.new()
	generator.mix_rate = sample_rate
	generator.buffer_length = 0.1
	audio_player.stream = generator
	audio_player.volume_db = -12.0
	add_child(audio_player)

func start_bgm() -> void:
	audio_player.play()
	playback = audio_player.get_stream_playback()
	is_playing = true

func _process(delta: float) -> void:
	if not is_playing or playback == null:
		return
		
	# Dynamic tempo switching (Low tempo: 0.8s per note, High tempo: 0.35s per note)
	var note_duration: float = 0.35 if tempo_fast else 0.85
	note_timer += delta
	if note_timer >= note_duration:
		note_timer = 0.0
		# Pick peaceful melody note (> 440 Hz)
		target_freq = melody_notes[randi() % melody_notes.size()]
		current_amp = 0.35
		
	# Decay amplitude smoothly for a gentle, peaceful bell/chime attack
	current_amp = lerp(current_amp, 0.0, delta * (8.0 if tempo_fast else 4.0))
	current_freq = lerp(current_freq, target_freq, delta * 10.0)

	_fill_audio_buffer()

func _fill_audio_buffer() -> void:
	if playback == null:
		return
	var frames_available: int = playback.get_frames_available()
	for i in range(frames_available):
		var increment: float = (current_freq * 2.0 * PI) / sample_rate
		phase = fmod(phase + increment, 2.0 * PI)
		# Pure sine wave with soft bell harmonics (> 440 Hz)
		var sample_val: float = sin(phase) * 0.7 + sin(phase * 2.0) * 0.3
		sample_val *= current_amp
		var vector_sample: Vector2 = Vector2(sample_val, sample_val)
		playback.push_frame(vector_sample)

# Public control API
func set_high_tempo() -> void:
	tempo_fast = true

func set_low_tempo() -> void:
	tempo_fast = false

func toggle_tempo() -> void:
	tempo_fast = !tempo_fast

