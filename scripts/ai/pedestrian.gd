extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var nav_agent: NavigationAgent3D = $nav_agent
@onready var timer: Timer = $timer;

var next_node
var search_cooldown = 5
var movement_delta: float

var state = "alive"

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	find_next_node()

func find_next_node():
	# Find a node to go to
	if next_node == null:
		next_node = get_tree().get_nodes_in_group("npc_walk_nodes").pick_random().get_children().pick_random();
		nav_agent.target_position = next_node.global_position

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if nav_agent.is_navigation_finished() && state == "alive":
		return
	movement_delta = SPEED * delta
	var next_path_position = nav_agent.get_next_path_position()
	var new_velocity = global_position.direction_to(next_path_position) * movement_delta
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_nav_agent_velocity_computed(new_velocity)
	

func _on_timer_timeout():
	find_next_node()

func _on_nav_agent_navigation_finished():
	next_node = null
	timer.start(search_cooldown)

func _on_nav_agent_velocity_computed(safe_velocity):
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)
