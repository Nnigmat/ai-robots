extends Spatial

const Robot = preload("res://entities/Robot.tscn") 
const Brush = preload("res://entities/Brush.tscn") 

export var AMOUNT: int = 4
export var ROBOTS_PER_ROW: int = 10 
export var STROKE_FLOW: float = 0.2
export var ROBOT_SPEED: int = 4
export(String, 'No avoidance', 'First attempt', 'Priority') var COLLISION_TYPE = Globals.NO_AVOIDANCE
export(String, 'Order', 'Color') var DIVISION_TYPE = 'Order'

var done_robots = 0
var collisions = 0
var paints = 0
var timer = 0
var is_done = false
var to_hide = true

func _ready():
	$Info/Done.text = 'Done: ' + str(done_robots) + ' / ' + str(AMOUNT)
	$Info/Collisions.text = 'Collisions: ' + str(collisions / 2)
	$Info/Paint.text = 'Paints: ' + str(paints)
	$Info/Timer.text = 'Timer:  ' + str(timer)
	
	var canvas = get_parent().get_node('Canvas')
	
	for i in range(AMOUNT / ROBOTS_PER_ROW + 1):
		for j in range(ROBOTS_PER_ROW):
			if i * ROBOTS_PER_ROW + j >= AMOUNT:
				continue
				
			var robot = Robot.instance()
			var brush = Brush.instance()
			
			brush.stroke_flow = STROKE_FLOW
			brush.turn_off()
			brush.connect("painted", self, "_on_paint_painted")
			
			robot.add_child(brush)
			robot.COLLISION_TYPE = COLLISION_TYPE
			robot.robots_amount = AMOUNT
			robot.STEP = ROBOT_SPEED
			robot.CANVAS_DIMS = [canvas.width, canvas.height]
			robot.DIVISION_TYPE = DIVISION_TYPE
			robot.id = i * ROBOTS_PER_ROW + j
			robot.initial_position = Vector3(- i * 250, 3, j * 250)
			robot.set_name('Robot ' + str(i))

			robot.connect("done", self, "_on_robot_done")
			robot.connect("collide", self, "_on_robot_collide")
			$ImageProcessor.connect("pass_data", robot, "_on_ImageProcessor_pass_data")
	
			add_child(robot)


func _on_robot_done():
	done_robots += 1
	$Info/Done.text = 'Done: ' + str(done_robots) + ' / ' + str(AMOUNT)
	
	is_done = done_robots == AMOUNT


func _on_robot_collide():
	collisions += 1
	$Info/Collisions.text = 'Collisions: ' + str(collisions / 2)


func _on_paint_painted():
	paints += 1
	$Info/Paint.text = 'Paints: ' + str(paints)


func _on_Button_pressed(): 
	for child in get_children():
		if not 'Robot' in child.get_name():
			continue
			
		if to_hide:
			child.hide()
		else:
			child.show()
			
	to_hide = not to_hide


func _on_ImageProcessor_pass_image(path):
	var image = load(path)
	$ProcessedImage/Sprite.texture = image


func _on_Timer_timeout():
	if is_done:
		$Timer.stop()
		
	timer += 1
	$Info/Timer.text = 'Timer:  ' + _to_mm_ss(timer)


func _to_mm_ss(seconds):
	var mm = seconds / 60
	var ss = seconds - mm * 60
	
	if mm < 10:
		mm = '0' + str(mm)
		
	if ss < 10:
		ss = '0' + str(ss)
		
	return str(mm) + ':' + str(ss)


func _on_Show_grid_Button_pressed():
	get_node('/root/Game/Canvas').toggle_lines()
