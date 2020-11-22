extends MeshInstance

signal done()
signal collide()


# The bigger STEP, the faster algo working, but it loses quality, due not reaching the cell fully
export var STEP = 1
export var can_input: bool = true
export var line_order: int = 0
export var robots_amount: int = 4
export var draw_polylines: bool = true
export var initial_position: Vector3 = Vector3(1, 3, 1)
export var direction: Vector3 = Vector3(1, 3, 1)
export var INPUT_DELAY: float = 0.4
export var COLLISION_TYPE: String = Globals.NO_AVOIDANCE


var current_delay: float = 0.0
var polylines = []
var polyline = []
var target: Vector3 = Vector3(1, 3, 1)
var polyline_start = true
var emitted_done = false
var can_emmit = false
var material = null
var close_robots = []
var init_origin = null


func hide():
	visible = false

	
func show():
	visible = true


func _check_state():
	if not draw_polylines or emitted_done:
		return 
		
	if len(polylines) != 0 and len(polyline) == 0 and _near_target():
		polyline = polylines.pop_back()
		polyline_start = true
		_turn_off_brush()
	
	if len(polyline) != 0 and _near_target() and polyline_start:
		var cell = polyline.pop_back()
		target = Vector3(cell.x, 2, cell.y)
		polyline_start = false
		
	if len(polyline) != 0 and _near_target() and not polyline_start:
		var cell = polyline.pop_back()
		target = Vector3(cell.x, 2, cell.y)
		_turn_on_brush()
	
	if len(polylines) == 0 and _near_target() and can_emmit: 
		emitted_done = true
		emit_signal("done")
		_turn_off_brush()
		material.albedo_color = Color(0, 1, 0)


func get_average():
	var res = Vector3(0, 0, 0)
	
	if len(close_robots) == 0:
		return res
		
	var player_loc = get_global_transform().origin
	for r in close_robots:
		print(r.direction)
		res += (player_loc - r.direction).normalized()
	return res / len(close_robots)


func _ready():
	material = SpatialMaterial.new()
	set_material_override(material)
	
	var location = get_global_transform()
	init_origin = initial_position + location.origin
	location.origin = init_origin
	set_global_transform(location)
	
	direction = init_origin
	target = init_origin


func _process(delta):
#	_user_move()
	_check_state()
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
	var params = {
		'type': COLLISION_TYPE, 
		'location': direction, 
		'target': target, 
		'speed': STEP
	}
	direction += Motion.move(params)
	
# Signals

func _on_ImageProcessor_pass_data(data):
	var tmp = [[Vector2(init_origin.x, init_origin.z)]]
	for i in range(int(float(len(data)) / robots_amount * line_order), 
		int(float(len(data)) / robots_amount * (line_order + 1))):
		tmp.append(data[i])

	polylines = tmp


func _turn_on_brush():
	$Brush.turn_on()
	material.albedo_color = Color(1, 0, 0)
	
	
func _turn_off_brush():
	$Brush.turn_off()
	material.albedo_color = Color(1, 1, 1)


func _on_Timer_timeout():
	can_emmit = true


func _on_Area_area_exited(area):
	if area.get_name() == 'Area':
		emit_signal("collide")


func _on_Vision_area_entered(area):
	if area.get_name() == 'Vision':
		close_robots.append(area.get_parent())


func _on_Vision_area_exited(area):
	if area.get_name() == 'Vision':
		close_robots.erase(area.get_parent())
