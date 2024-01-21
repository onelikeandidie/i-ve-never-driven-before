extends VehicleBody3D

@export var MAX_STEER = 0.8
@export var ENGINE_POWER: Array[int] = [0, 120, 170, 300, 400]
@export var MINIUMIN_SPEED: Array[int] = [0, 0, 8, 16, 32]
@export var base_grip = 10.4;
@export var grip_multiplier = -0.1;

@onready var car_honk = preload("res://sounds/car/car_honk.wav")
@onready var car_engine_start = preload("res://sounds/car/engine_start.wav")
@onready var car_engine_accelarating = preload("res://sounds/car/engine_accelarating.wav")
@onready var car_engine_accelarating_loop = preload("res://sounds/car/engine_accelarating_loop.wav")
@onready var car_engine_idle = preload("res://sounds/car/engine_idle_wav.tres")
@onready var car_honk_player = $car_honk
@onready var engine_sound_player = $engine_sound
@onready var accelaration_sound_player = $accelaration_sound
@onready var wheels: Dictionary = {
	"front_left": $front_left,
	"front_right": $front_right,
	"back_left": $back_left,
	"back_right": $back_right,
}

var gear = 0;
@onready var _max_gears = MINIUMIN_SPEED.size()
var state = "idle"
var current_grip = 1
var accelarating = false

signal engine_started()

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	engine_sound_player.finished.connect(_on_engine_sound_player_finished)

func _update_grip():
	current_grip = 1 + grip_multiplier * gear;
	wheels["front_left"].wheel_friction_slip = base_grip + base_grip * current_grip
	wheels["front_right"].wheel_friction_slip = base_grip + base_grip * current_grip
	wheels["back_left"].wheel_friction_slip = base_grip + base_grip * current_grip * 0.8
	wheels["back_right"].wheel_friction_slip = base_grip + base_grip * current_grip * 0.8

func _process(delta):
	if state == "idle":
		return
	# Even if the car is going backwards, use negative gears kekw
	#var speed = abs(linear_velocity.length());
	#if MINIUMIN_SPEED[gear] < speed:
	#	gear_down()
	# Check next gear
	#if _max_gears > gear + 1 && MINIUMIN_SPEED[gear + 1] <= speed:
	#	gear_up()

func _on_engine_sound_player_finished():
	engine_sound_player.stream = car_engine_idle
	engine_sound_player.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if state == "idle":
		return
	var speed = abs(linear_velocity.length());
	steering = move_toward(steering, Input.get_axis("steer_right", "steer_left") * MAX_STEER, delta * 2.5)
	if MINIUMIN_SPEED[gear] < speed:
		engine_force = Input.get_axis("backward", "forward") * ENGINE_POWER[gear]

func gear_down():
	gear -= 1
	if gear < 0:
		gear = 0
		return
	_update_grip()

func gear_up():
	gear += 1
	if gear >= _max_gears:
		gear = _max_gears - 1
		return
	_update_grip()

func _input(event):
	if event.is_action_pressed("gear_down"):
		gear_down()
	if event.is_action_pressed("gear_up"):
		gear_up()
	if event.is_action_pressed("honk"):
		car_honk_player.stream = car_honk
		car_honk_player.play()
	if state == "idle" && event.is_action_pressed("start_car"):
		state = "engine_started"
		engine_sound_player.stream = car_engine_start
		engine_sound_player.play()
		engine_started.emit()
	if state == "engine_started" && gear > 0:
		if event.is_action_pressed("forward") || event.is_action_pressed("backward"):
			accelarating = true
			accelaration_sound_player.play()
		if event.is_action_released("forward") || event.is_action_pressed("backward"):
			accelarating = false
			accelaration_sound_player.stop()
