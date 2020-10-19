extends Spatial

const Robot = preload("res://entities/Robot.tscn") 
const Brush = preload("res://entities/Brush.tscn") 

export var AMOUNT: int = 4

var done_robots = 0

func _ready():
	
	for i in range(AMOUNT):
		var robot = Robot.instance()
		var brush = Brush.instance()
		
		robot.add_child(brush)
		robot.robots_amount = AMOUNT
		robot.line_order = i
		robot.connect("done", self, "_on_robot_done")
		$ImageProcessor.connect("pass_data", robot, "_on_ImageProcessor_pass_data")

		add_child(robot)
		
func _on_robot_done():
	done_robots += 1
	print(done_robots)
