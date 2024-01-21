extends Node3D

const starting_lines: Array[String] = [
	"Ready for your driving exam?",
	"You better have studied well for this one"
]

const waiting_lines: Array[String] = [
	"You can start the engine now...",
	"Alright lets get going"
]

const teaching_lines: Array[String] = [
	"This car has manual gears",
	"The faster you go, the less grip you have",
	"Not that you'll go fast, since we are in a town",
	"Any mistakes and I will FAIL your driving exam"
]

@onready var timer = $timer
@onready var voice = ["pedro_mad_adjusted","erica_nice","maia_normal"].pick_random()

@export var cooldown = 3.0

var state = "starting"
var player: VehicleBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	if player == null:
		player = get_tree().get_nodes_in_group("player")[0]
	player.engine_started.connect(_on_player_engine_started)
	
	timer.start(cooldown)

func _on_player_engine_started():
	state = "teaching"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Get the game camera
	var camera: Camera3D = get_viewport().get_camera_3d()
	var screen_position = camera.unproject_position(global_position)
	DialogManager.update_box_position(screen_position)

func _say_the_line_bart():
	# Get the game camera
	var camera: Camera3D = get_viewport().get_camera_3d()
	var screen_position = camera.unproject_position(global_position)
	var lines: Array[String] = [];
	match state:
		"starting":
			lines.push_front(starting_lines.pick_random())
			state = "waiting"
		"waiting":
			lines.push_front(waiting_lines.pick_random())
			state = "idle"
		"teaching":
			lines = teaching_lines
			state = "idle"
	
	if !lines.is_empty():
		DialogManager.start_dialog(screen_position, lines, voice, 1)

func _on_timer_timeout():
	_say_the_line_bart()
