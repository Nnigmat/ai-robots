extends Spatial

const Robot = preload("res://entities/Robot.tscn") 
const Brush = preload("res://entities/Brush.tscn") 

export var AMOUNT: int = 4
export var ROBOTS_PER_ROW: int = 10 

var done_robots = 0
var collisions = 0

func _ready():
	$CanvasLayer/Done.text = 'Done: ' + str(done_robots) + ' / ' + str(AMOUNT)
	$CanvasLayer/Collisions.text = 'Collisions: ' + str(collisions / 2)

	for i in range(AMOUNT / ROBOTS_PER_ROW):
		for j in range(ROBOTS_PER_ROW):
			if i * ROBOTS_PER_ROW + j + 1 > AMOUNT:
				continue
				
			var robot = Robot.instance()
			var brush = Brush.instance()
			
			brush.turn_off()
			
			robot.add_child(brush)
			robot.robots_amount = AMOUNT
			robot.line_order = i * ROBOTS_PER_ROW + j
			robot.initial_position = Vector3(- i * 100, 3, j*100)

			robot.connect("done", self, "_on_robot_done")
			robot.connect("collide", self, "_on_robot_collide")
			$ImageProcessor.connect("pass_data", robot, "_on_ImageProcessor_pass_data")
	
			add_child(robot)
		
func _on_robot_done():
	done_robots += 1
	$CanvasLayer/Done.text = 'Done: ' + str(done_robots)

func _on_robot_collide():
	collisions += 1
	$CanvasLayer/Collisions.text = 'Collisions: ' + str(collisions / 2)
