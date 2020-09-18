extends MeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var direction: Vector3 = Vector3(1, 1, 1)
export var INPUT_DELAY: float = 0.4
export var STEP = 1
var current_delay: float = 0.0
var can_input: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not can_input:
		current_delay += delta
		
	if current_delay < INPUT_DELAY and not can_input:
		return
	else:
		current_delay = 0
		can_input = true
		
	if Input.is_action_pressed("ui_up"):
		direction += Vector3(STEP, 0, 0)
		can_input = false
	elif Input.is_action_pressed("ui_down"):
		direction += Vector3(-STEP, 0, 0)
		can_input = false
	elif Input.is_action_pressed("ui_right"):
		direction += Vector3(0, 0, STEP)
		can_input = false
	elif Input.is_action_pressed("ui_left"):
		direction += Vector3(0, 0, -STEP)
		can_input = false
		
	var player_loc = get_global_transform()
	player_loc.origin = direction
	set_global_transform(player_loc)
	
	
