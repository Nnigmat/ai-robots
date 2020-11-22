extends Spatial


func move(params):
	if params['type'] == Globals.NO_AVOIDANCE:
		return no_avoidance(params)
	else:
		return Vector3(0, 0, 0)
	
func no_avoidance(params):
	var shift = Vector3(0, 0, 0)
	
	var speed = params['speed']
	var target = params['target']
	var location = params['location']
	
	if target.x < location.x:
		shift.x = -speed
	elif target.x > location.x:
		shift.x = speed
	
	if target.z < location.z:
		shift.z = -speed
	elif target.z > location.z:
		shift.z = speed
	
	return shift
