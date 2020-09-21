extends MeshInstance

export var INPUT_DELAY: float = 0.4
export var STEP = 1
export var can_input: bool = true
export var line_order: int = 0
export var robots_amount: int = 4
export var draw_polylines: bool = true

var direction: Vector3 = Vector3(1, 2, 1)
var current_delay: float = 0.0
var polylines = []
var polyline = []
var target: Vector3 = Vector3(1, 2, 1)
var polyline_start = true

func _process(delta):	
	_user_move()
	_move()

	# Apply movement
	var player_loc = get_global_transform()
	player_loc.origin = player_loc.origin.linear_interpolate(direction, delta * 4)
	set_global_transform(player_loc)
	
func _user_move():
	if not can_input:
		return
	
	if Input.is_action_pressed("ui_up"):
		direction += Vector3(STEP, 0, 0)
	if Input.is_action_pressed("ui_down"):
		direction += Vector3(-STEP, 0, 0)
	if Input.is_action_pressed("ui_right"):
		direction += Vector3(0, 0, STEP)
	if Input.is_action_pressed("ui_left"):
		direction += Vector3(0, 0, -STEP)
	if Input.is_action_just_pressed("ui_select"):
		if $Brush.is_draw:
			$Brush.turn_off()
		else:
			$Brush.turn_on()
		
func _near_target():
	return abs(direction.x - target.x) <= STEP and abs(direction.z - target.z) <= STEP
	
func _move():
	if not draw_polylines:
		return 
		
	if len(polylines) != 0 and len(polyline) == 0 and _near_target():
		polyline = polylines.pop_back()
		polyline_start = true
		$Brush.turn_off()
	
	if len(polyline) != 0 and _near_target() and polyline_start:
		var cell = polyline.pop_back()
		target = Vector3(cell.x, 2, cell.y)
		polyline_start = false
		
	if len(polyline) != 0 and _near_target() and not polyline_start:
		$Brush.turn_on()
		var cell = polyline.pop_back()
		target = Vector3(cell.x, 2, cell.y)
	
	var shift = Vector3(0, 0, 0)
	
	if target.x < direction.x:
		shift.x = -STEP
	elif target.x > direction.x:
		shift.x = STEP
	
	if target.z < direction.z:
		shift.z = -STEP
	elif target.z > direction.z:
		shift.z = STEP
	
	direction += shift
		
	
func _on_ImageProcessor_pass_data(data):
	var tmp = []
	for i in range(len(data) / 4 * line_order, len(data) / 4 * (line_order + 1)):
		tmp.append(data[i])
	polylines = tmp
	
