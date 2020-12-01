extends Spatial


func move(params: Dictionary):
	var robot = params.get('robot')
	var type = params.get('type')
	var speed = params.get('speed')
	var target = params.get('target')
	var location = params.get('location')
	var close_robots = params.get('close_robots')
	var width = params.get('width')
	var height = params.get('height')
	
	if type == Globals.NO_AVOIDANCE:
		return no_avoidance(speed, target, location)
	elif type == Globals.FIRST_ATTEMPT:
		return first_attempt(speed, target, location, close_robots)
	elif type == Globals.PRIORITY:
		return priority(robot, speed, target, location, close_robots, width, height)
	else:
		return Vector3(0, 0, 0)
	
	
func no_avoidance(speed, target, location):
	var shift = Vector3(0, 0, 0)
	
	if target.x < location.x:
		shift.x = -speed
	elif target.x > location.x:
		shift.x = speed
	
	if target.z < location.z:
		shift.z = -speed
	elif target.z > location.z:
		shift.z = speed
	
	return shift
	
	
func get_average(close_robots):
	var res = Vector3(0, 0, 0)
	
	if not close_robots or len(close_robots) == 0:
		return res
		
	var player_loc = get_global_transform().origin
	for r in close_robots:
		res += (player_loc - r.direction).normalized()
		
	res.y = 0
	return res / len(close_robots)
	
	
func first_attempt(speed, target, location, close_robots):
	return no_avoidance(speed, target, location) - get_average(close_robots) * speed


func is_highest_priority(robot, close_robots):
	for r in close_robots:
		if r.id > robot.id:
			return false
	
	return true

	
func add_obstacle(map: Array, position: Vector2, size: int):
	if position.x < 0 or position.y < 0:
		return
	
	for i in range(position.x - (size - 1)):
		for j in range(position.y - (size - 1)):
			if i < 0 or i >= len(map):
				continue
				
			if j < 0 or j >= len(map[i]):
				continue
				
			map[i][j] = 1
				

func priority(robot, speed, target, location, close_robots, width, height):
	if len(close_robots) > 0:
		return no_avoidance(speed, target, location)
	
	if not is_highest_priority(robot, close_robots):
		return Vector3(0, 0, 0)
	
	var map = []
	for i in range(height):
		map.append([])
		for j in range(width):
			map[i].append(0)
			
	for r in close_robots:
		var r_location = r.direction
		add_obstacle(map, Vector2(r_location.x, r_location.z), Globals.ROBOT_SIZE)
	
	
