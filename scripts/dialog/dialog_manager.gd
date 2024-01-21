extends Node

@onready var text_box_scene = preload("res://scenes/dialog/text_box.tscn")

var dialog_lines: Array[String] = []
var current_line_index = 0

var text_box
var text_box_position: Vector2

var is_dialog_active = false
var can_advance_line = false

var voice = "default"
var voice_files = {
	"pedro_mad_adjusted": [
		"res://sounds/voices/pedro_mad_adjusted/pedro_mad_adjusted-1.wav",
		"res://sounds/voices/pedro_mad_adjusted/pedro_mad_adjusted-2.wav",
		"res://sounds/voices/pedro_mad_adjusted/pedro_mad_adjusted-3.wav",
		"res://sounds/voices/pedro_mad_adjusted/pedro_mad_adjusted-4.wav",
		"res://sounds/voices/pedro_mad_adjusted/pedro_mad_adjusted-5.wav",
		"res://sounds/voices/pedro_mad_adjusted/pedro_mad_adjusted-6.wav",
		"res://sounds/voices/pedro_mad_adjusted/pedro_mad_adjusted-7.wav",
		"res://sounds/voices/pedro_mad_adjusted/pedro_mad_adjusted-8.wav",
		"res://sounds/voices/pedro_mad_adjusted/pedro_mad_adjusted-9.wav",
		"res://sounds/voices/pedro_mad_adjusted/pedro_mad_adjusted-10.wav",
		"res://sounds/voices/pedro_mad_adjusted/pedro_mad_adjusted-11.wav",
		"res://sounds/voices/pedro_mad_adjusted/pedro_mad_adjusted-12.wav",
		"res://sounds/voices/pedro_mad_adjusted/pedro_mad_adjusted-13.wav",
		"res://sounds/voices/pedro_mad_adjusted/pedro_mad_adjusted-14.wav",
	],
	"erica_nice": [
		"res://sounds/voices/erica_nice/erica_nice-1.wav",
		"res://sounds/voices/erica_nice/erica_nice-2.wav",
		"res://sounds/voices/erica_nice/erica_nice-3.wav",
		"res://sounds/voices/erica_nice/erica_nice-4.wav",
		"res://sounds/voices/erica_nice/erica_nice-5.wav",
		"res://sounds/voices/erica_nice/erica_nice-6.wav",
		"res://sounds/voices/erica_nice/erica_nice-7.wav",
		"res://sounds/voices/erica_nice/erica_nice-8.wav",
		"res://sounds/voices/erica_nice/erica_nice-9.wav",
		"res://sounds/voices/erica_nice/erica_nice-10.wav",
		"res://sounds/voices/erica_nice/erica_nice-11.wav",
		"res://sounds/voices/erica_nice/erica_nice-12.wav",
		"res://sounds/voices/erica_nice/erica_nice-13.wav",
	],
	"maia_normal": [
		"res://sounds/voices/maia_normal/maia_normal-1.wav",
		"res://sounds/voices/maia_normal/maia_normal-2.wav",
		"res://sounds/voices/maia_normal/maia_normal-3.wav",
		"res://sounds/voices/maia_normal/maia_normal-4.wav",
		"res://sounds/voices/maia_normal/maia_normal-5.wav",
		"res://sounds/voices/maia_normal/maia_normal-6.wav",
		"res://sounds/voices/maia_normal/maia_normal-7.wav",
		"res://sounds/voices/maia_normal/maia_normal-8.wav",
		"res://sounds/voices/maia_normal/maia_normal-9.wav",
		"res://sounds/voices/maia_normal/maia_normal-10.wav",
	]
}

func start_dialog(pos: Vector2, lines: Array[String], voice: String, index: int):
	if is_dialog_active:
		# Just add the lines to the current dialog
		for line in lines:
			dialog_lines.push_front(line)
		return
		
	dialog_lines = lines
	text_box_position = pos
	self.voice = voice
	
	_show_text_box()
	
	is_dialog_active = true

func update_box_position(pos: Vector2):
	text_box_position = pos
	if text_box != null:
		text_box.update_position(text_box_position)

func _show_text_box():
	# Create new text box and add the dialog
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_box_finished_displaying)
	get_tree().root.add_child(text_box)
	text_box.global_position = text_box_position
	text_box.voice = voice
	text_box.display_text(dialog_lines[current_line_index])
	can_advance_line = false
	
func _on_text_box_finished_displaying():
	can_advance_line = true

func _unhandled_input(event):
	if is_dialog_active && can_advance_line && event.is_action_pressed("advance_dialog"):
		text_box.queue_free()
		
		current_line_index += 1
		if current_line_index < dialog_lines.size():
			return _show_text_box()
		
		# We ran out of lines lol
		is_dialog_active = false
		current_line_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load all the voices
	for voice_index in voice_files:
		for voice_file_index in range(voice_files[voice_index].size()):
			var voice_file = voice_files[voice_index][voice_file_index]
			voice_files[voice_index][voice_file_index] = load(voice_file)
			print("Loaded voice: " + voice_file)
			pass
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
