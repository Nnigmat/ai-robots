extends MeshInstance

export var INPUT_DELAY: float = 0.4
export var STEP = 1

var direction: Vector3 = Vector3(1, 2, 1)
var current_delay: float = 0.0
var can_input: bool = true

func _process(delta):
		
	if Input.is_action_pressed("ui_up"):
		direction += Vector3(STEP, 0, 0)
		can_input = false
	if Input.is_action_pressed("ui_down"):
		direction += Vector3(-STEP, 0, 0)
		can_input = false
	if Input.is_action_pressed("ui_right"):
		direction += Vector3(0, 0, STEP)
		can_input = false
	if Input.is_action_pressed("ui_left"):
		direction += Vector3(0, 0, -STEP)
		can_input = false
		
	var player_loc = get_global_transform()
	player_loc.origin = player_loc.origin.linear_interpolate(direction, delta * 4)
	set_global_transform(player_loc)
	
	
