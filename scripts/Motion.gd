extends Spatial


func move(params):
	var type = params.get('type')
	var speed = params.get('speed')
	var target = params.get('target')
	var location = params.get('location')
	var close_robots = params.get('close_robots')
	
	if type == Globals.NO_AVOIDANCE:
		return no_avoidance(speed, target, location)
	elif type == Globals.FIRST_ATTEMPT:
		return first_attempt(speed, target, location, close_robots)
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
