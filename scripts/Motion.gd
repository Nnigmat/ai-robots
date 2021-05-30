extends Spatial

var state = [] 
var path = []
var path_index = 0

export(float, 0, 10, 0.01) var stroke_width: float = 1 
export(Color, RGB) var stroke_color = Color(0.2, 0.2, 0.2)
export(Mesh) var stroke_shape = PlaneMesh.new()
var material = SpatialMaterial.new()
var move_state = 0

func move(params: Dictionary):
	var robot = params.get('robot')
	var type = params.get('type')
	var speed = params.get('speed')
	var target = params.get('target')
	var location = params.get('location')
	var close_robots = params.get('close_robots')
	var width = params.get('width')
	var height = params.get('height')
	var radius = params.get('radius')
	var close_robots_changed = params.get('close_robots_changed')
	var path_length = params.get('path_length')
	var robot_radius = params.get('robot_radius')
	
	if type == Globals.NO_AVOIDANCE:
		return no_avoidance(speed, target, location)
	elif type == Globals.FIRST_ATTEMPT:
		return first_attempt(speed, target, location, close_robots)
	elif type == Globals.PRIORITY:
		return priority(robot, speed, target, location, close_robots, width, height, close_robots_changed, path_length, radius, robot_radius)
	elif type == Globals.BUG:
		return bug(robot, close_robots, speed, target, location, robot_radius)
	elif type == Globals.BACKOFF:
		return backoff(robot, close_robots, speed, target, location)
	else:
		return Vector3(0, 0, 0)
	
func draw_path():
	for el in path:
		var mesh_instance = MeshInstance.new()
		mesh_instance.set_mesh(stroke_shape)
		mesh_instance.set_material_override(material)
		mesh_instance.transform.origin = el
		mesh_instance.scale = Vector3(stroke_width, stroke_width, stroke_width)
#		mesh_instance.get_surface_material(0).albedo_color = stroke_color
		get_parent().get_parent().add_child(mesh_instance)
	
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


func priority(robot, speed, target, location, close_robots, width, height, close_robots_changed, path_length, radius, robot_radius):
	# If no robots nearby just do no avoidance
	if len(close_robots) == 1:
		return no_avoidance(speed, target, location)

	# If we have robots nearby and the robot is not the highest priority - freeze
	if not is_highest_priority(robot, close_robots):
		return Vector3(0, 0, 0)
	
	# If robot near its closest temp point, take the next one
	if len(path) != 0 and len(path) > path_index and near_target(location, path[path_index], speed):
		path_index += 1
		
	# If point exist, do no_avoidance to this point
	if len(path) > path_index:
		return no_avoidance(speed, path[path_index], location)
	
	# Otherwise do A* search
	var blocked_points = []
	for r in close_robots:
		if r.id != robot.id:
			blocked_points.append(r.direction)
	
	var astar = init_astar(location.x, location.z, radius, robot_radius, blocked_points, width, height)

	var limited_target = target
	if (target - location).length() > path_length:
		limited_target = (target - location).normalized() * path_length + location
	
#	print(astar.FindPath(location.x, location.z, limited_target.x, limited_target.z))
	var next = astar.FindPath(location.x, location.z, int(limited_target.x), int(limited_target.z))
#	print(location.x, ' ', location.z, ' ', int(limited_target.x), ' ', int(limited_target.z), ' ', radius, ' ', robot_radius, ' ', blocked_points)
	
	if not next.empty():
		path = toVector3Array(next)
		draw_path()
	
	return Vector3(0, 0, 0)

func init_astar(x, y, radius, robot_radius, blocked_points, width, height):
	var astar = gdAstar.new()
	
	for i in range(width):
		for j in range(height):
			for point in blocked_points:
				if point.x == i and point.y == j:
					continue
				
				astar.AddPoint(i, j)
				
	return astar

func toVector3Array(array):
	var res = []
	for el in array:
		res.append(Vector3(el.x, 0, el.y))
	return res

func near_target(direction, target, step):
	return abs(direction.x - target.x) <= step and abs(direction.z - target.z) <= step

func dist_between_p(a, b):
	return sqrt(pow((a.x - b.x), 2) + pow((a.z - b.z), 2))
	
func point_inside_rect(point, a, b, c, d):
	var rect_area = dist_between_p(a, b) * dist_between_p(b, c)
	var triangles_area = triangle_area(point, a, b) + triangle_area(point, b, c) + triangle_area(point, c, d) + triangle_area(point, d, a)
	
	return abs(rect_area - triangles_area) < 1
	
func triangle_area(a, b, c):
	return abs(a.x * (b.z - c.z) + b.x * (c.z - a.z) + c.x * (a.z - b.z)) / 2

func has_obstacle(robot, location, target, close_robots):
	location.y = 2
	target.y = 2
	
	var 	lower = location
	var upper = target
	if location.z > target.z:
		lower = target
		upper = location

	var v = upper - lower
	var u = v.normalized()
	
	var delta_ort
	if upper.x == target.x:
		delta_ort = Vector3(0, 0, 1) * 100
	elif upper.z == target.z:
		delta_ort = Vector3(1, 0, 0) * 100
	else:
		var a = (upper.z - lower.z) / (upper.x - lower.x) 
		delta_ort = Vector3(1, 0, -1/a).normalized() * 100

	# Delta along the line
	var delta_along = u * 10
	delta_along.y = 0
	
	
	var A = lower + delta_ort - delta_along
	var B = upper + delta_ort + delta_along
	var C = upper - delta_ort + delta_along
	var D = lower - delta_ort - delta_along
	
	A.y = 2
	B.y = 2
	C.y = 2
	D.y = 2
	print(A, B, C, D, location, target, close_robots[1].direction)
	
	for _robot in close_robots:
		if _robot.id == robot.id:
			continue 
		
		_robot.direction.y = 2
		if not point_inside_rect(_robot.direction, A, B, C, D):
			return false
		
	return true
 

func move_along(robot, close_robots, speed, target, location, radius):
	var moves = []
	if target.z > location.z:
		moves = [Vector3(0, 0, speed), Vector3(speed, 0, 0), Vector3(0, 0, -speed), Vector3(-speed, 0, 0)]
	else:
		moves = [Vector3(0, 0, -speed), Vector3(speed, 0, 0), Vector3(0, 0, speed), Vector3(-speed, 0, 0)]
		
	for _robot in close_robots:
		if _robot.id == robot.id:
			continue
		
		if _robot.direction - location > moves[move_state].normalized() * radius * 3:
			return moves[move_state]
		elif _robot.direction - location > moves[(move_state + 1) % 4].normalized() * radius * 3:
			move_state = (move_state + 1) % 4
			return moves[move_state]
			
		
#		elif _robot.direction - location > moves[(move_state - 1) % 4]:
#			move_state = (move_state - 1) % 4
#			return moves[move_state]
			
	if move_state + 1 == 4:
		move_state = 0
	else:
		move_state += 1
	
	return Vector3(0, 0, 0)
	
func bug(robot, close_robots, speed, target, location, radius):
	if len(close_robots) == 1:
		return no_avoidance(speed, target, location)

	if not is_highest_priority(robot, close_robots):
		return Vector3(0, 0, 0)
		
	if not has_obstacle(robot, location, target, close_robots):
		return no_avoidance(speed, target, location)

	return move_along(robot, close_robots, speed, target, location, radius)
	
func backoff(robot, close_robots, speed, target, location):
	if len(close_robots) == 1:
		return no_avoidance(speed, target, location)

	if not is_highest_priority(robot, close_robots):
		return Vector3(0, 0, 0)
