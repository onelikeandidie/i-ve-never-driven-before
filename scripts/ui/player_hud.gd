extends CanvasLayer

@export var player: VehicleBody3D

# Debug UI
@onready var debug_container = $debug
@onready var car_state_label = $debug/HBoxContainer3/car_state_value
@onready var grip_label = $debug/HBoxContainer4/grip_value
var _debug_shown

# Car UI
@onready var gear_label = $hud/HBoxContainer/PanelContainer/gear_value
@onready var speed_label = $hud/HBoxContainer/PanelContainer2/MarginContainer/HBoxContainer/speed_value

# Hint UI
@onready var hints = {
	'engine_off': $hint/engine_off,
	'driving': $hint/driving,
}
var hint_state

# Called when the node enters the scene tree for the first time.
func _ready():
	hint_state = 'engine_off'
	if player == null:
		player = get_tree().get_nodes_in_group("player")[0]
	
	player.engine_started.connect(_on_engine_started)
	update_hints()

func _on_engine_started():
	hint_state = 'driving'
	update_hints()

func update_hints():
	for hint_group in hints:
		if hint_group == hint_state:
			hints[hint_group].show()
			continue
		hints[hint_group].hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _debug_shown:
		update_debug()
	
	update_gear()
	update_speed()

func update_gear():
	gear_label.text = str(player.gear)

func update_speed():
	var speed = player.linear_velocity.length()
	speed_label.text = str(round(speed))

func update_debug():
	var car_state = player.state
	car_state_label.text = car_state
	var grip = player.base_grip + player.base_grip * player.current_grip
	grip_label.text = str(grip)

func _unhandled_input(event):
	if event.is_action_pressed("toggle_debug"):
		toggle_debug()

func toggle_debug():
	if _debug_shown:
		debug_container.hide()
	else:
		debug_container.show()
	_debug_shown = !_debug_shown


