extends MeshInstance

signal done()
signal collide()

onready var Motion = $Motion

# The bigger STEP, the faster algo working, but it loses quality, due not reaching the cell fully
export var STEP = 1
export var can_input: bool = true
export var id: int = 0
export var robots_amount: int = 4
export var draw_polylines: bool = true
export var initial_position: Vector3 = Vector3(1, 3, 1)
export var direction: Vector3 = Vector3(1, 3, 1)
export var INPUT_DELAY: float = 0.4
export var COLLISION_TYPE: String = Globals.NO_AVOIDANCE
export var CANVAS_DIMS = [Globals.SIZE, Globals.SIZE]
export var PATH_LENGTH = 70
export var RADIUS = 300
export var ROBOT_RADIUS = 20
export var DEFAULT_COLOR = Color('#000')

# Как делить линии между роботами, второе значение 'Color'
export var DIVISION_TYPE = 'Order'

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
var close_robots_changed = false
var path = []
var path_index = 0
var freeze = false


func hide():
	visible = false

	
func show():
	visible = true


func _check_state():
	if not draw_polylines or emitted_done:
		return 
		
	if len(polylines) != 0 and len(polyline) == 0 and _near_target():
		var tmp = polylines.pop_back()
		polyline = tmp['points']
		_change_brush(tmp['color'], tmp['width'])
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
		id = -1
		emit_signal("done")
		_turn_off_brush()
		material.albedo_color = Color(0, 1, 0)


func _ready():
	material = SpatialMaterial.new()
	material.albedo_color = DEFAULT_COLOR
	set_material_override(material)
	scale = Vector3(Globals.ROBOT_SIZE, Globals.ROBOT_SIZE, Globals.ROBOT_SIZE)
	
	var location = get_global_transform()
	init_origin = initial_position + location.origin
	location.origin = init_origin
	set_global_transform(location)
	
	direction = init_origin
	target = init_origin


func _process(delta):
#	_user_move()
	if emitted_done:
		return

	_check_state()
	_move()

	# Apply movement
	var player_loc = get_global_transform()
	player_loc.origin = direction
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

func _near(a, b, distance):
	return abs(a.x - b.x) <= distance and abs(a.z - b.z) <= distance

func _near_target():
	var _robot_near_point = false
	for _robot in close_robots:
		if _near(_robot.direction, target, STEP * 5):
			_robot_near_point = true
		
	if _robot_near_point:
		return abs(direction.x - target.x) <= STEP * 5 and abs(direction.z - target.z) <= STEP * 5
		
	return abs(direction.x - target.x) <= STEP and abs(direction.z - target.z) <= STEP

func _move():
	var params = {
		'robot': self,
		'type': COLLISION_TYPE, 
		'location': direction, 
		'target': target, 
		'speed': STEP,
		'close_robots': close_robots,
		'close_robots_changed': close_robots_changed,
		'width': CANVAS_DIMS[0],
		'height': CANVAS_DIMS[1],
		'path_length': PATH_LENGTH,
		'radius': RADIUS,
		'robot_radius': ROBOT_RADIUS,
	}

	direction += Motion.move(params)
	
	close_robots_changed = false

# Signals
func _on_ImageProcessor_pass_data(data):
	var tmp = [{
		'points': [Vector2(init_origin.x, init_origin.z)],
		'width': 0,
		'color': null
	}]
	
	if DIVISION_TYPE == 'Order':
		for i in range(int(float(len(data)) / robots_amount * id), 
			int(float(len(data)) / robots_amount * (id + 1))):
			tmp.append(data[i])

	elif DIVISION_TYPE == 'Color':
		var colors = []
		for polyline in data:
			if not colors.has(polyline['color']):
				colors.append(polyline['color'])
				
		var color = colors[id]
		for polyline in data:
			if polyline['color'] == color:
				tmp.append(polyline)
	
	polylines = tmp

func _change_brush(color, width):
	$Brush.change_brush(color, width) 

func _turn_on_brush():
	$Brush.turn_on()
	material.albedo_color = Color(1, 0, 0)
	
	
func _turn_off_brush():
	$Brush.turn_off()
	material.albedo_color = DEFAULT_COLOR


func _on_Timer_timeout():
	can_emmit = true


func _on_Area_area_exited(area):
	if area.get_name() == 'Area':
		emit_signal("collide")


func _on_Vision_area_entered(area):
	if area.get_name() == 'Area':
		close_robots.append(area.get_parent())
		close_robots_changed = true


func _on_Vision_area_exited(area):
	if area.get_name() == 'Area':
		close_robots.erase(area.get_parent())
		close_robots_changed = true
