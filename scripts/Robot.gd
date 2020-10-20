extends MeshInstance

signal done()
signal collide()

export var INPUT_DELAY: float = 0.4
export var STEP = 1
export var can_input: bool = true
export var line_order: int = 0
export var robots_amount: int = 4
export var draw_polylines: bool = true
export var initial_position: Vector3 = Vector3(1, 3, 1)

var direction: Vector3 = Vector3(1, 3, 1)
var current_delay: float = 0.0
var polylines = []
var polyline = []
var target: Vector3 = Vector3(1, 3, 1)
var polyline_start = true
var emitted_done = false
var can_emmit = false
var material = null

func hide():
	visible = false
	
func show():
	visible = true

func _ready():
	material = SpatialMaterial.new()
	set_material_override(material)
	
	var location = get_global_transform()
	var new_origin = initial_position + location.origin
	location.origin = new_origin
	set_global_transform(location)
	
	direction = new_origin
	target = new_origin


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
	for i in range(len(data) / robots_amount * line_order, len(data) / robots_amount * (line_order + 1)):
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
	emit_signal("collide")
