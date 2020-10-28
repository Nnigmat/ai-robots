extends Spatial

const Robot = preload("res://entities/Robot.tscn") 
const Brush = preload("res://entities/Brush.tscn") 

export var AMOUNT: int = 4
export var ROBOTS_PER_ROW: int = 10 
export var STROKE_FLOW: float = 0.2
export var ROBOT_SPEED: int = 4

var done_robots = 0
var collisions = 0
var paints = 0
var to_hide = true

func _ready():
	$Info/Done.text = 'Done: ' + str(done_robots) + ' / ' + str(AMOUNT)
	$Info/Collisions.text = 'Collisions: ' + str(collisions / 2)
	$Info/Paint.text = 'Paints: ' + str(paints)
	
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
			robot.robots_amount = AMOUNT
			robot.STEP = ROBOT_SPEED
			robot.line_order = i * ROBOTS_PER_ROW + j
			robot.initial_position = Vector3(- i * 100, 3, j*100)
			robot.set_name('Robot' + str(i))

			robot.connect("done", self, "_on_robot_done")
			robot.connect("collide", self, "_on_robot_collide")
			$ImageProcessor.connect("pass_data", robot, "_on_ImageProcessor_pass_data")
	
			add_child(robot)


func _on_robot_done():
	done_robots += 1
	$Info/Done.text = 'Done: ' + str(done_robots) + ' / ' + str(AMOUNT)


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
