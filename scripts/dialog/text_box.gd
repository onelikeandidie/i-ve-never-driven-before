extends Control

@onready var label = $inner_box/MarginContainer/displayed_text
@onready var timer = $timer
@onready var player = $sound_player
@onready var inner_box = $inner_box
@onready var hint_box = $hint_box

@export var max_width = 256
@export var text = ""
@export var letter_time = 0.03
@export var space_time = 0.06
@export var punctuation_time = 0.2
@export var death_time = 3
@export var voice = "default"

var cursor = 0;

var current_sound = 0
var is_finished_displaying = false
var offset: Vector2

signal finished_displaying()

func display_text(text: String):
	if timer == null:
		timer = get_node("timer")
	if inner_box == null:
		inner_box = get_node("inner_box")
	if label == null:
		label = get_node("inner_box/MarginContainer/displayed_text")
	self.text = text
	if text.is_empty():
		printerr("Dialog text box is empty")
		return
	label.text = self.text
	hint_box.hide()
	
	await resized
	custom_minimum_size.x = min(size.x, max_width)
	
	if size.x > max_width:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized # wait for x resize
		await resized # wait for y resize
	
	offset = Vector2(size.x / 2, size.y + 24)
	global_position -= offset
	
	label.text = ""
	_display_letter()
	_play_next_sound()
	
func update_position(pos: Vector2):
	global_position = lerp(global_position, pos - offset, 0.2)
	
func _display_letter():
	if cursor >= text.length():
		timer.start(death_time)
		is_finished_displaying = true
		finished_displaying.emit()
		hint_box.show()
		return

	label.text += text[cursor]
	
	match text[cursor]:
		"!", ".", ",", "?":
			timer.start(punctuation_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(letter_time)
	
	cursor += 1

func _on_timer_timeout():
	_display_letter()

func _play_next_sound():
	if is_finished_displaying:
		return
	if player == null:
		get_node("sound_player")
	
	var sound = DialogManager.voice_files[voice].pick_random();
	player.stream = sound
	player.play(0)

func _on_sound_player_finished():
	_play_next_sound();
