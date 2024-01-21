extends Node3D

@export var following: Node3D
@export var offset: Vector3
@export var offset_away: Vector3 = Vector3(0, 4, -7)

@onready var camera = $Camera3D

const MODES = ["close","away"]
var _current_mode = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_physics_process(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var target = _get_real_offset()
	global_position = lerp(global_position, target, delta * 3)
	camera.look_at(following.global_position, Vector3.UP)

func _get_real_offset() -> Vector3:
	var current_offset
	match _current_mode:
		0:
			current_offset = offset
		1:
			current_offset = offset_away
	return following.global_position + current_offset.rotated(following.rotation.normalized(), fmod(abs(following.rotation.y), PI))

func _input(event):
	if event.is_action_pressed("change_camera_mode"):
		_current_mode += 1
		if _current_mode > MODES.size() - 1:
			_current_mode = 0
