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
	var close_robots_changed = params.get('close_robots_changed')
	var path_length = params.get('path_length')
	
	if type == Globals.NO_AVOIDANCE:
		return no_avoidance(speed, target, location)
	elif type == Globals.FIRST_ATTEMPT:
		return first_attempt(speed, target, location, close_robots)
	elif type == Globals.PRIORITY:
		return priority(robot, speed, target, location, close_robots, width, height, close_robots_changed, path_length)
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

	
func add_obstacle(map, position: Vector2, size: int, width, height):
	if position.x < 0 or position.y < 0:
		return
	
	for i in range(position.x - (size - 1)):
		for j in range(position.y - (size - 1)):
			if i < 0 or i >= width:
				continue
				
			if j < 0 or j >= height:
				continue
				
			map[Vector2(i, j)] = {
				path = false,
				traversable = false
			}
				

func astar(grid, start_idxv, end_idxv, length):
	var pq = preload("res://scripts/PriorityQueue.gd").new()
	pq.make()
	var traversed = {}	
	var tmp = _evaluate_grid_samethread(pq, traversed, grid, start_idxv.x, start_idxv.y, 
		start_idxv.x, start_idxv.y, end_idxv.x, end_idxv.y, length)
		
	# Convert to 3D space
	var result = []
	for el in tmp:
		result.append(Vector3(el.x, 1, el.y))
	return result
	

func _distance(a, b):
	var ab_x = abs(b.x-a.x)
	var ab_y = abs(b.y-a.y)
	return sqrt(abs(ab_x*ab_x+ab_y*ab_y))
	
func _grid_traverse_queue(pq, traversed, grid, curr, prev, to):

	if !grid.has(curr):
		return
	
	if grid[curr].has('traversable'):
		if grid[curr]['traversable'] == false:
			return
	
	var gx = _distance(prev, curr)
	var hx = _distance(curr, to) 
	var curr_weight = -(gx+hx)
	
	## Weights could never be lower, because of priority_queue
	var already_visited = traversed.has(curr) # || (traversed[curr] != null && traversed[curr].weight > curr_weight)
	
	if already_visited:
		return
		
	traversed[curr] = {
		curr = curr,	
		prev = prev,
		weight = curr_weight,
	}
	
	pq.push({
		curr = curr,
		prev = prev,
		pqval = curr_weight
	})
	

func _evaluate_grid_samethread(pq, traversed, grid, i, j, start_i, start_j, end_i, end_j, length):
	return _evaluate_grid( 
		[{
			pq = pq, 
			traversed = traversed, 
			grid = grid, 
			i = i,
			j = j,
			start_i = start_i,
			start_j = start_j,
			end_i = end_i,
			end_j = end_j,
			length = length
		}])

func _evaluate_grid(userdata):
	var pq = userdata[0].pq
	var traversed = userdata[0].traversed
	var grid = userdata[0].grid
	var start_i = userdata[0].start_i
	var start_j = userdata[0].start_j
	var path_length = userdata[0].length
	var current_probe = 0
	var maximum_probe = 100000
	
	## TCO
	while true:
		var i = userdata[0].i
		var j = userdata[0].j
		var end_i = userdata[0].end_i
		var end_j = userdata[0].end_j

		var curr = Vector2(i, j)
		var end = Vector2(end_i, end_j)
		_grid_traverse_queue(pq, traversed, grid, Vector2(i-1,j), curr, end)
		_grid_traverse_queue(pq, traversed, grid, Vector2(i+1,j), curr, end)
		_grid_traverse_queue(pq, traversed, grid, Vector2(i,j-1), curr, end)
		_grid_traverse_queue(pq, traversed, grid, Vector2(i,j+1), curr, end)	
		
		_grid_traverse_queue(pq, traversed, grid, Vector2(i-1,j-1), curr, end)
		_grid_traverse_queue(pq, traversed, grid, Vector2(i-1,j+1), curr, end)
		_grid_traverse_queue(pq, traversed, grid, Vector2(i+1,j+1), curr, end)
		_grid_traverse_queue(pq, traversed, grid, Vector2(i+1,j-1), curr, end)
		
		if pq.empty():
			return []
			
		var top = pq.top()
		pq.pop()
		current_probe += 1
		
		var path = []
		_get_path(grid, traversed, Vector2(start_i, start_j), Vector2(i, j), Vector2(start_i, start_j), path)

		if path_length < len(path):
			return path
		
		if i == end_i and j == end_j:
			var result = []
			var start = Vector2(start_i, start_j)
			var begin = Vector2(end.x, end.y)
			_get_path(grid, traversed, start, end, begin, result)
			return result
		elif current_probe > maximum_probe:
			return []
		else:			
			userdata[0].i = top.curr.x
			userdata[0].j = top.curr.y


func _get_path(grid, traversed, start, end, curr, result):
	while true:
		if curr == start:
			result.push_front(curr)
			return
		result.push_front(curr)
		curr = traversed[curr].prev		


func priority(robot, speed, target, location, close_robots, width, height, close_robots_changed, path_length):
	if len(close_robots) == 0 or not close_robots_changed:
		return no_avoidance(speed, target, location)
	
	if not is_highest_priority(robot, close_robots):
		return Vector3(0, 0, 0)
	
	var map = {}
	for i in range(height):
		for j in range(width):
			map[Vector2(i, j)] = {
				path = false,
				traversable = true
			}
			
	for r in close_robots:
		var r_location = r.direction
		add_obstacle(map, Vector2(r_location.x, r_location.z), Globals.ROBOT_SIZE, width, height)
	
	return astar(map, Vector2(location.x, location.z), Vector2(target.x, target.z), path_length)
