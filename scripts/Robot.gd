extends RigidBody


export var SPEED = 5
var movement = Vector3()

func _integrate_forces(state):
	movement = Vector3(0, 0, 0)
	
	if Input.is_action_pressed("ui_left"):
		movement.x = 1
	if Input.is_action_pressed("ui_right"):
		movement.x = -1
	if Input.is_action_pressed("ui_up"):
		movement.z = 1
	if Input.is_action_pressed("ui_down"):
		movement.z = -1
		
	add_force(Vector3(movement.x * SPEED, 0, movement.z * SPEED), Vector3(0, 0, 0))
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
